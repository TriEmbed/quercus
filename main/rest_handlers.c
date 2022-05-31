/* HTTP Restful API Server

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include <string.h>
#include <fcntl.h>
#include "esp_http_server.h"
#include "esp_system.h"
#include "esp_log.h"
#include "esp_vfs.h"
#include "cJSON.h"
#include <time.h>
#include "esp_system.h"
#include "esp_partition.h"
#include "esp_random.h"
#include "esp_chip_info.h"
#include "nvs_flash.h"
#include "nvs.h"
#include"i2c.h"
#include "OTAServer.h"

cJSON * wifi_scan (void);  // from wifi.c



static const char *REST_TAG = "esp-rest";
#define REST_CHECK(a, str, goto_tag, ...)                                              \
    do                                                                                 \
    {                                                                                  \
        if (!(a))                                                                      \
        {                                                                              \
            ESP_LOGE(REST_TAG, "%s(%d): " str, __FUNCTION__, __LINE__, ##__VA_ARGS__); \
            goto goto_tag;                                                             \
        }                                                                              \
    } while (0)

#define FILE_PATH_MAX (ESP_VFS_PATH_MAX + 128)
#define SCRATCH_BUFSIZE (10240)

typedef struct rest_server_context
{
  char base_path[ESP_VFS_PATH_MAX + 1];
  char scratch[SCRATCH_BUFSIZE];
} rest_server_context_t;

#define CHECK_FILE_EXTENSION(filename, ext) (strcasecmp(&filename[strlen(filename) - strlen(ext)], ext) == 0)

/* Set HTTP response content type according to file extension */
static esp_err_t
set_content_type_from_file (httpd_req_t * req, const char *filepath)
{
  const char *type = "text/plain";
  if (CHECK_FILE_EXTENSION (filepath, ".html")) {
    type = "text/html";
  } else if (CHECK_FILE_EXTENSION (filepath, ".js")) {
    type = "application/javascript";
  } else if (CHECK_FILE_EXTENSION (filepath, ".css")) {
    type = "text/css";
  } else if (CHECK_FILE_EXTENSION (filepath, ".png")) {
    type = "image/png";
  } else if (CHECK_FILE_EXTENSION (filepath, ".ico")) {
    type = "image/x-icon";
  } else if (CHECK_FILE_EXTENSION (filepath, ".svg")) {
    type = "text/xml";
  }
  return httpd_resp_set_type (req, type);
}

/* Send HTTP response with the contents of the requested file */
static esp_err_t
rest_common_get_handler (httpd_req_t * req)
{
  char filepath[FILE_PATH_MAX];

  rest_server_context_t *rest_context = (rest_server_context_t *) req->user_ctx;
  strlcpy (filepath, rest_context->base_path, sizeof (filepath));
  if (req->uri[strlen (req->uri) - 1] == '/') {
    strlcat (filepath, "/index.html", sizeof (filepath));
  } else {
    strlcat (filepath, req->uri, sizeof (filepath));
  }
  int fd = open (filepath, O_RDONLY, 0);
  if (fd == -1) {
    ESP_LOGE (REST_TAG, "Failed to open file : %s", filepath);
    /* Respond with 500 Internal Server Error */
    httpd_resp_send_err (req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to read existing file");
    return ESP_FAIL;
  }

  set_content_type_from_file (req, filepath);

  char *chunk = rest_context->scratch;
  ssize_t read_bytes;
  do {
    /* Read file in chunks into the scratch buffer */
    read_bytes = read (fd, chunk, SCRATCH_BUFSIZE);
    if (read_bytes == -1) {
      ESP_LOGE (REST_TAG, "Failed to read file : %s", filepath);
    } else if (read_bytes > 0) {
      /* Send the buffer contents as HTTP response chunk */
      if (httpd_resp_send_chunk (req, chunk, read_bytes) != ESP_OK) {
	close (fd);
	ESP_LOGE (REST_TAG, "File sending failed!");
	/* Abort sending file */
	httpd_resp_sendstr_chunk (req, NULL);
	/* Respond with 500 Internal Server Error */
	httpd_resp_send_err (req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to send file");
	return ESP_FAIL;
      }
    }
  } while (read_bytes > 0);
  /* Close file after sending complete */
  close (fd);
  ESP_LOGI (REST_TAG, "File sending complete");
  /* Respond with an empty chunk to signal HTTP response completion */
  httpd_resp_send_chunk (req, NULL, 0);
  return ESP_OK;
}




/* Simple handler for getting temperature data */
static esp_err_t
cors_header (httpd_req_t * req)
{
  printf("=========================================================================\n");
  httpd_resp_set_type (req, "application/json");
  httpd_resp_set_hdr(req,"Access-Control-Allow-Origin", "*");
  httpd_resp_set_hdr(req,"Access-Control-Max-Age", "600");
  httpd_resp_set_hdr(req,"Access-Control-Allow-Methods", "PATCH,PUT,POST,GET,OPTIONS");
  httpd_resp_set_hdr(req,"Access-Control-Allow-Headers", "*");

    
  return ESP_OK;
}

/* Simple handler for getting temperature data */
static esp_err_t
cors_handler (httpd_req_t * req)
{
  cors_header ( req);
  httpd_resp_sendstr (req, NULL);
  return ESP_OK;
}



/* Simple handler for light brightness control */
static esp_err_t
light_brightness_post_handler (httpd_req_t * req)
{
  int total_len = req->content_len;
  int cur_len = 0;
  char *buf = ((rest_server_context_t *) (req->user_ctx))->scratch;
  int received = 0;
  if (total_len >= SCRATCH_BUFSIZE) {
    /* Respond with 500 Internal Server Error */
    httpd_resp_send_err (req, HTTPD_500_INTERNAL_SERVER_ERROR, "content too long");
    return ESP_FAIL;
  }
  while (cur_len < total_len) {
    received = httpd_req_recv (req, buf + cur_len, total_len);
    if (received <= 0) {
      /* Respond with 500 Internal Server Error */
      httpd_resp_send_err (req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to post control value");
      return ESP_FAIL;
    }
    cur_len += received;
  }
  buf[total_len] = '\0';

  cJSON *root = cJSON_Parse (buf);
  int red = cJSON_GetObjectItem (root, "red")->valueint;
  int green = cJSON_GetObjectItem (root, "green")->valueint;
  int blue = cJSON_GetObjectItem (root, "blue")->valueint;
  ESP_LOGI (REST_TAG, "Light control: red = %d, green = %d, blue = %d", red, green, blue);
  cJSON_Delete (root);
  httpd_resp_sendstr (req, "Post control value successfully");
  return ESP_OK;
}




// system_get_time - Get the system time measured in microseconds since last device start-up.
// esp_chip_info - Get information about the chip.
// esp_get_free_heap_size - Get the amount of free heap size.
// esp_get_idf_version - Get the version of the ESP-IDF in use.
// esp_wifi_scan_get_ap_records - Retrieve the access points found in a previous scan.
// esp_wifi_scan_get_ap_num - Retrieve the count of found access points from a previous scan.
// esp_wifi_get_auto_connect - Determine whether or not auto connect at boot is enabled.
// esp_wifi_get_bandwidth - Get the current bandwidth setting.
// esp_wifi_get_channel - Get the current channel.
// esp_wifi_get_config - Retrieve the current connection information associated with the specified WiFi interface.
// esp_wifi_get_country - Retrieve the currently configured WiFi country.
// esp_wifi_get_mac - Retrieve the current MAC address for the interface.
// esp_wifi_get_modees - Get the WiFi operating mode.
// esp_wifi_get_promiscuous
// esp_wifi_get_protocol - Get the 802.11 protocol (b/g/n).
// esp_wifi_get_ps - Get the power save type.
// esp_wifi_get_station_list - Get the list of stations connected to ESP32 when it is behaving as an access point.
// tcpip_adapter_get_ip_info
// tcpip_adapter_get_sta_list
// tcpip_adapter_get_wifi_if

/* Simple handler for getting system handler */
static esp_err_t
system_info_get_handler (httpd_req_t * req)
{
// wifi_mode_t *mode;

//const char * wifi_mode ="wifi_mode";
  esp_chip_info_t chip_info;
  esp_chip_info (&chip_info);
  //esp_wifi_get_mode(&mode);

  extern unsigned char i2c_gpio_scl;
  extern unsigned char i2c_gpio_sda;


  ESP_LOGI (REST_TAG, "Start test");
  esp_partition_iterator_t iter = esp_partition_find (ESP_PARTITION_TYPE_APP, ESP_PARTITION_SUBTYPE_ANY, NULL);
  ESP_LOGI (REST_TAG, "Name, type, subtype, offset, length");
  while (iter != NULL) {
    const esp_partition_t *partition = esp_partition_get (iter);
    ESP_LOGI (REST_TAG, "%s, app, %d, 0x%x, 0x%x (%d)", partition->label, partition->subtype, partition->address, partition->size, partition->size);
    iter = esp_partition_next (iter);
  }

  esp_partition_iterator_release (iter);
  iter = esp_partition_find (ESP_PARTITION_TYPE_DATA, ESP_PARTITION_SUBTYPE_ANY, NULL);
  while (iter != NULL) {
    const esp_partition_t *partition = esp_partition_get (iter);
    ESP_LOGI (REST_TAG, "%s, data, %d, 0x%x, 0x%x (%d)", partition->label, partition->subtype, partition->address, partition->size, partition->size);
    iter = esp_partition_next (iter);
  }

  esp_partition_iterator_release (iter);


  cJSON *root = cJSON_CreateObject ();
  cJSON_AddStringToObject (root, "CPU", CONFIG_IDF_TARGET);
  cJSON_AddStringToObject (root, "version", IDF_VER);
#ifdef CONFIG_STA_WIFI_SSID  
  cJSON_AddStringToObject (root, "Connected SSID",CONFIG_STA_WIFI_SSID);
#endif
#ifdef CONFIG_AP_WIFI_SSID
  cJSON_AddStringToObject (root, "Internal SSID", CONFIG_AP_WIFI_SSID);
#endif            
  cJSON_AddNumberToObject (root, "cores", chip_info.cores);
  cJSON_AddNumberToObject (root, "firmware", CONFIG_IDF_FIRMWARE_CHIP_ID);
  cJSON_AddNumberToObject (root, "Total Heap Size (Kb)", heap_caps_get_total_size (MALLOC_CAP_32BIT) / 1024);
  cJSON_AddNumberToObject (root, "Free Space (Kb)", heap_caps_get_free_size (MALLOC_CAP_32BIT) / 1024);
  cJSON_AddNumberToObject (root, "DRAM (Kb)", heap_caps_get_free_size (MALLOC_CAP_8BIT) / 1024);
  cJSON_AddNumberToObject (root, "DRAM (Kb)", (heap_caps_get_free_size (MALLOC_CAP_32BIT) - heap_caps_get_free_size (MALLOC_CAP_8BIT)) / 1024);
  cJSON_AddNumberToObject (root, "SCL", i2c_gpio_scl);
  cJSON_AddNumberToObject (root, "SDA", i2c_gpio_sda);
//    cJSON_AddNumberToObject (root, "system_get_time", esp_system_get_time());
//    cJSON_AddNumberToObject (root, "esp_chip_info", esp_chip_info ());
//    cJSON_AddStringToObject (root, " esp_get_idf_version",  esp_get_idf_version ());
// 
//switch(mode){
//case WIFI_MODE_NULL :
//  cJSON_AddStringToObject (root, wifi_mode, "null mode");
//  break;
// case WIFI_MODE_STA:
//  cJSON_AddStringToObject (root, wifi_mode,"WiFi station mode");
//  break;

// case WIFI_MODE_AP:
// cJSON_AddStringToObject (root, wifi_mode,"WiFi soft-AP mode");
// break;
// case  WIFI_MODE_APSTA:
// cJSON_AddStringToObject (root, wifi_mode,"WiFi station + soft-AP mode");
// break;
// case WIFI_MODE_MAX:
// cJSON_AddStringToObject (root, wifi_mode,"Wifi max mode");
// break;
// }

  const char *sys_info = cJSON_Print (root);
  ESP_LOGI (REST_TAG, "%s", sys_info);
  cors_header ( req);
  httpd_resp_sendstr (req, sys_info);
  free ((void *) sys_info);
  cJSON_Delete (root);
  return ESP_OK;
}


/* Simple handler for getting temperature data */
static esp_err_t
temperature_data_get_handler (httpd_req_t * req)
{
  
  cJSON *root = cJSON_CreateObject ();
  cJSON_AddNumberToObject (root, "raw", esp_random () % 20);
  const char *sys_info = cJSON_Print (root);
  cors_header ( req);
  httpd_resp_sendstr (req, sys_info);
  free ((void *) sys_info);
  cJSON_Delete (root);
  return ESP_OK;
}


/* Simple handler for getting temperature data */
static esp_err_t
get_ssid_handler (httpd_req_t * req)
{
  
  cJSON *root = cJSON_CreateObject ();
  cJSON_AddItemToObject (root, "ssid", wifi_scan ());
  const char *sys_info = cJSON_Print (root);
  cors_header ( req);
  httpd_resp_sendstr (req, sys_info);
  free ((void *) sys_info);
  cJSON_Delete (root);
  return ESP_OK;
}





/* Simple handler getting i2s node */
static esp_err_t
i2c_handler (httpd_req_t * req)
{
  const char *dump_tag = "dump";
  const char *eeprom_tag = "eeprom";
  const char *nvram_tag = "nvram";
  const char *i2cset_tag = "i2cset";
  const char *i2cget_tag = "i2cget";
  const char *i2cscan_tag = "i2cscan";
 //////////////////i2cscan_tag///
  const int total_len = req->content_len;
  int cur_len = 0;
  char *buf = ((rest_server_context_t *) (req->user_ctx))->scratch;
  int received = 0;


  if (total_len >= SCRATCH_BUFSIZE) {
    /* Respond with 500 Internal Server Error */
    httpd_resp_send_err (req, HTTPD_500_INTERNAL_SERVER_ERROR, "content too long");
      return ESP_FAIL;
  }
  while (cur_len < total_len) {
    received = httpd_req_recv (req, buf + cur_len, total_len);
    if (received <= 0) {
      /* Respond with 500 Internal Server Error */
      httpd_resp_send_err (req, HTTPD_500_INTERNAL_SERVER_ERROR, "Failed to post control value");
      return ESP_FAIL;
    }
    cur_len += received;
  }
  buf[total_len] = '\0';
  printf ("%s\n", buf);
  cJSON *input = cJSON_Parse (buf);

  printf ("input=%s \n", cJSON_Print (input));


  cJSON *root = cJSON_CreateObject ();
  cJSON *  current_element = NULL;


  cJSON_ArrayForEach ( current_element, input) {
    cJSON *parm[3];
    
     char *current_key = current_element->string ;


    if (current_key == NULL) { // this will never happen
      continue;
    }
    const int size = cJSON_GetArraySize (current_element);

    printf ("current key %s arrary size %d\n", current_key, size);
    switch (size) {
    case 0:{ // scan takes no parameter
      if (strncmp (current_key, i2cscan_tag,strlen(i2cscan_tag)) == 0) {
       printf("scanning\n"); 
	     cJSON_AddItemToObject (root, i2cscan_tag, i2cScan ());
      }

    } // end case
    break;
    case 2:{
     parm[0] = cJSON_GetArrayItem (current_element, 0);
	   parm[1] = cJSON_GetArrayItem (current_element, 1);
	   
     if (!cJSON_IsNumber (parm[0])) { // check that this first is a number
	     break;
	   }

	  
	   if (!cJSON_IsNumber (parm[1])) { // check that the second is a numeber
	     break;
	   }
     // show me the numbers
	   printf ("%s *parm[0]=%d *parm[0]=%d\n ", current_key, parm[0]->valueint, parm[1]->valueint);
	   // dump is vestigial
     if (strcmp (current_key, dump_tag) == 0) {
	     cJSON_AddItemToObject (root, dump_tag, i2cDump (parm[0]->valueint, parm[1]->valueint));
	     break;
	   } else if (strcmp (current_key, eeprom_tag) == 0) {
	     cJSON_AddItemToObject (root, eeprom_tag, i2cDump (parm[0]->valueint, parm[1]->valueint));
	     break;
	   } else if (strcmp (current_key, nvram_tag) == 0) {
	     cJSON_AddItemToObject (root, nvram_tag, i2cDump (parm[0]->valueint, parm[1]->valueint));
	     break;
	   }
	   } // end case
      break;
    case 3:{ // here we have three parameter
  	 parm[0] = cJSON_GetArrayItem (current_element, 0);
	   parm[1] = cJSON_GetArrayItem (current_element, 1);
	   parm[2] = cJSON_GetArrayItem (current_element, 2);
	   
     if (strcmp (current_key, i2cget_tag) == 0) {
	     cJSON_AddItemToObject (root, i2cget_tag, i2cget (parm[0]->valueint, parm[1]->valueint, parm[2]->valueint));
	       break;
	     }
        if (strcmp (current_key, i2cset_tag) == 0) { // set takes a list as the second
       cJSON_AddItemToObject (root, i2cset_tag, i2cset (parm[0]->valueint,parm[1]->valueint, 
                                              parm[1]));
       break;
     }
      } // end case
    } // end switch
  }// end loop

  const char *sys_info = cJSON_Print (root);
  printf("%s\n",sys_info);
  cors_header ( req);
  httpd_resp_sendstr (req, sys_info);
  free ((void *) sys_info);
  cJSON_Delete (root);
  cJSON_Delete (input);
  return ESP_OK;
}


const struct
{
  char *path;
    esp_err_t (*handler) (httpd_req_t *);
  int method;
}

#define NELEMS(x)  (sizeof(x) / sizeof((x)[0]))


// https://www.esp32.com/viewtopic.php?t=12649
static commandPath[] = {
  /* URI handler for getting web server files */
  {"/api/v1/light/brightness", light_brightness_post_handler, HTTP_POST},
  {"/api/v1/temp/raw", temperature_data_get_handler, HTTP_GET},
  {"/api/v1/system/info", cors_handler, HTTP_OPTIONS},
  {"/api/v1/system/info", system_info_get_handler, HTTP_GET},
  {"/api/v1/i2c", cors_handler, HTTP_OPTIONS},
  {"/api/v1/i2c", i2c_handler, HTTP_PATCH},
  { "/status",OTA_update_status_handler,HTTP_POST},
  { "/wifi",get_ssid_handler,HTTP_GET},
//  {"/api/v1/i2c", esp_handler, HTTP_PATCH},

  // {"/api/v1/dialog/test/>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>post", dialog_test_post_handler, HTTP_POST},
  // {"/api/v1/dialog/control/get", dialog_control_get_handler, HTTP_GET},
  // {"/api/v1/dialog/control/post", dialog_control_post_handler, HTTP_POST},
//  {"/api/v1/dialog/data/get", dialog_data_get_handler, HTTP_GET},
//  {"/api/v1/dialog/gpio/get", dialog_gpio_get_handler, HTTP_GET},
//  {"/api/v1/dialog", dialog_post_handler, HTTP_POST},

  {"/*", rest_common_get_handler, HTTP_GET},
};


void setup_cors (httpd_handle_t server);

esp_err_t
start_rest_server (const char *base_path)
{
  REST_CHECK (base_path, "wrong base path", err);
  rest_server_context_t *rest_context = calloc (1, sizeof (rest_server_context_t));
  REST_CHECK (rest_context, "No memory for rest context", err);
  strlcpy (rest_context->base_path, base_path, sizeof (rest_context->base_path));

  httpd_handle_t server = NULL;
  httpd_config_t config = HTTPD_DEFAULT_CONFIG ();
  config.uri_match_fn = httpd_uri_match_wildcard;
  config.max_uri_handlers   = 12;
  config.max_resp_headers   = 12;
  ESP_LOGI (REST_TAG, "Starting HTTP Server");
  REST_CHECK (httpd_start (&server, &config) == ESP_OK, "Start server failed", err_start);

#ifdef   CONFIG_AARDVARK_TEST
  i2cDump (8, 4);
  i2cDump (9, 4);
#endif
  /////////////////////////////////////////////
  for (int n = 0; n < NELEMS (commandPath); n++) {

    httpd_uri_t uri = {
      .uri = commandPath[n].path,
      .method = commandPath[n].method,
      .handler = commandPath[n].handler,
      .user_ctx = rest_context
    };
    httpd_register_uri_handler (server, &uri);
  }
#ifdef CONFIG_AARDVARK_CORS
  setup_cors (server);
#endif
  return ESP_OK;
err_start:
  free (rest_context);
err:
  return ESP_FAIL;
}
