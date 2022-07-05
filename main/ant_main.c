/* HTTP Restful API Server Example

   This example code is in the Public Domain (or CC0 licensed, at your option.)

   Unless required by applicable law or agreed to in writing, this
   software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
   CONDITIONS OF ANY KIND, either express or implied.
*/
#include "sdkconfig.h"
#include "driver/gpio.h"
#include "esp_vfs_semihost.h"
#include "esp_vfs_fat.h"
#include "esp_spiffs.h"
#include "sdmmc_cmd.h"
#include "nvs_flash.h"
#include "esp_netif.h"
#include "esp_event.h"
#include "esp_log.h"
#include "mdns.h"
#include "esp_wifi.h"
#include "lwip/apps/netbiosns.h"
#include "esp_system.h"
#include "esp_vfs.h"
#include "cJSON.h"
#include "i2c.h"
#include "esp_mac.h"
static const char *TAG = __FILE__;

#include "apsta.h"

extern cJSON *wifi_scan (void);

//#define SOFTAP
void NonVolatile_main (void);

#ifndef SOFTAP

#include "protocol_examples_common.h"

#endif

#if CONFIG_EXAMPLE_WEB_DEPLOY_SD
#include "driver/sdmmc_host.h"
#endif

static bool SOFTAP = false;
#define MDNS_INSTANCE "esp home web server"

void setup_slg ();


esp_event_handler_instance_t instance_any_id;

esp_err_t start_rest_server (const char *base_path);


static void
initialise_mdns (void)
{
uint8_t derived_mac_addr[6] = {0};
  //Get MAC address for Ethernet
  ESP_ERROR_CHECK(esp_read_mac(derived_mac_addr, ESP_MAC_WIFI_STA));
  ESP_LOGI("Ethernet MAC", "0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x",
  derived_mac_addr[0], derived_mac_addr[1], derived_mac_addr[2],
  derived_mac_addr[3], derived_mac_addr[4], derived_mac_addr[5]);

  char  tmp[32];
  sprintf( tmp,"%s-%02x%02x",
  CONFIG_EXAMPLE_MDNS_HOST_NAME,derived_mac_addr[4], derived_mac_addr[5] );
  printf("mdns name %s.local\n",tmp);
  mdns_init ();
  mdns_hostname_set (tmp);
  mdns_instance_name_set (MDNS_INSTANCE);

  mdns_txt_item_t serviceTxtData[] = {
    {"board", "esp32"},
    {"path", "/"}
  };

  ESP_ERROR_CHECK (mdns_service_add ("ESP32-WebServer", "_http", "_tcp", 80, serviceTxtData, sizeof (serviceTxtData) / sizeof (serviceTxtData[0])));
}


#if CONFIG_EXAMPLE_WEB_DEPLOY_SEMIHOST
esp_err_t
init_fs (void)
{
  esp_err_t ret = esp_vfs_semihost_register (CONFIG_EXAMPLE_WEB_MOUNT_POINT,
					     CONFIG_EXAMPLE_HOST_PATH_TO_MOUNT);
  if (ret != ESP_OK) {
    ESP_LOGE (TAG, "Failed to register semihost driver (%s)!", esp_err_to_name (ret));
    return ESP_FAIL;
  }
  return ESP_OK;
}
#endif

#if CONFIG_EXAMPLE_WEB_DEPLOY_SD
esp_err_t
init_fs (void)
{
  sdmmc_host_t host = SDMMC_HOST_DEFAULT ();
  sdmmc_slot_config_t slot_config = SDMMC_SLOT_CONFIG_DEFAULT ();

  gpio_set_pull_mode (15, GPIO_PULLUP_ONLY);	// CMD
  gpio_set_pull_mode (2, GPIO_PULLUP_ONLY);	// D0
  gpio_set_pull_mode (4, GPIO_PULLUP_ONLY);	// D1
  gpio_set_pull_mode (12, GPIO_PULLUP_ONLY);	// D2
  gpio_set_pull_mode (13, GPIO_PULLUP_ONLY);	// D3

  esp_vfs_fat_sdmmc_mount_config_t mount_config = {
    .format_if_mount_failed = true,
    .max_files = 4,
    .allocation_unit_size = 16 * 1024
  };

  sdmmc_card_t *card;
  esp_err_t ret = esp_vfs_fat_sdmmc_mount (CONFIG_EXAMPLE_WEB_MOUNT_POINT, &host,
					   &slot_config, &mount_config, &card);
  if (ret != ESP_OK) {
    if (ret == ESP_FAIL) {
      ESP_LOGE (TAG, "Failed to mount filesystem.");
    } else {
      ESP_LOGE (TAG, "Failed to initialize the card (%s)", esp_err_to_name (ret));
    }
    return ESP_FAIL;
  }
  /* print card info if mount successfully */
  sdmmc_card_print_info (stdout, card);
  return ESP_OK;
}
#endif

#if CONFIG_EXAMPLE_WEB_DEPLOY_SF
esp_err_t
init_fs (void)
{
  esp_vfs_spiffs_conf_t conf = {
    .base_path = CONFIG_EXAMPLE_WEB_MOUNT_POINT,
    .partition_label = NULL,
    .max_files = 5,
    .format_if_mount_failed = false
  };
  esp_err_t ret = esp_vfs_spiffs_register (&conf);

  if (ret != ESP_OK) {
    if (ret == ESP_FAIL) {
      ESP_LOGE (TAG, "Failed to mount or format filesystem");
    } else if (ret == ESP_ERR_NOT_FOUND) {
      ESP_LOGE (TAG, "Failed to find SPIFFS partition");
    } else {
      ESP_LOGE (TAG, "Failed to initialize SPIFFS (%s)", esp_err_to_name (ret));
    }
    return ESP_FAIL;
  }

  size_t total = 0, used = 0;
  ret = esp_spiffs_info (NULL, &total, &used);
  if (ret != ESP_OK) {
    ESP_LOGE (TAG, "Failed to get SPIFFS partition information (%s)", esp_err_to_name (ret));
  } else {
    ESP_LOGI (TAG, "Partition size: total: %d, used: %d", total, used);
  }
  return ESP_OK;
}
#endif


#define WIFI_SSID "ESP32 OTA Update"

/*
 * WiFi configuration
 */
static esp_err_t
softap_init (void)
{

  esp_err_t res = ESP_OK;

  res |= esp_netif_init ();
  res |= esp_event_loop_create_default ();
  esp_netif_create_default_wifi_ap ();

  wifi_init_config_t cfg = WIFI_INIT_CONFIG_DEFAULT ();
  res |= esp_wifi_init (&cfg);

  wifi_config_t wifi_config = {
    .ap = {
	   .ssid = WIFI_SSID,
	   .ssid_len = strlen (WIFI_SSID),
	   .channel = 6,
	   .authmode = WIFI_AUTH_OPEN,
	   .max_connection = 3},
  };

  res |= esp_wifi_set_mode (WIFI_MODE_AP);
  res |= esp_wifi_set_config (ESP_IF_WIFI_AP, &wifi_config);
  res |= esp_wifi_start ();

  return res;
}


void
blink_task (void *pvParameter)
{
  while (1) {
    printf ("Led Blinking here\n");
    vTaskDelay (1000 / portTICK_PERIOD_MS);
  }
}

#define ETH_ALEN 6
#define MAX_CONNECT_RETRY_ATTEMPTS  5
static bool s_reconnect = true;
static int s_retry_num = 0;
bool g_ap_started = false;
bool g_st_started = false;
uint8_t g_ap_channel;
uint8_t g_ap_bssid[ETH_ALEN];
// uint16_t g_scan_ap_num;
// wifi_ap_record_t *g_ap_list_buffer;
// const int FTM_REPORT_BIT = BIT0;
// const int FTM_FAILURE_BIT = BIT1;
// static uint32_t g_rtt_est, g_dist_est;
// static EventGroupHandle_t ftm_event_group;
// uint8_t g_ftm_report_num_entries;
// wifi_ftm_report_entry_t *g_ftm_report;
// // wifi_event_ap_probe_req_rx_t 
// static void
// event_handler (void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data)
// {
//   switch (event_id) {

//     //  case WIFI_EVENT_WIFI_READY (SYSTEM_EVENT_WIFI_READY)
//     //  case WIFI_EVENT_SCAN_DONE (SYSTEM_EVENT_SCAN_DONE)
//     //    wifi_event_sta_scan_done_t
//     //  case WIFI_EVENT_STA_AUTHMODE_CHANGE (SYSTEM_EVENT_STA_AUTHMODE_CHANGE)
//     //    wifi_event_sta_authmode_change_t
//     //  case WIFI_EVENT_STA_WPS_ER_SUCCESS (SYSTEM_EVENT_STA_WPS_ER_SUCCESS)
//     //  case WIFI_EVENT_STA_WPS_ER_FAILED (SYSTEM_EVENT_STA_WPS_ER_FAILED)
//     //    wifi_event_sta_wps_fail_reason_t
//     //  case WIFI_EVENT_STA_WPS_ER_TIMEOUT (SYSTEM_EVENT_STA_WPS_ER_TIMEOUT)
//     //  case WIFI_EVENT_STA_WPS_ER_PIN (SYSTEM_EVENT_STA_WPS_ER_PIN)
//     //    wifi_event_sta_wps_er_pin_t
//     //  case WIFI_EVENT_AP_STACONNECTED (SYSTEM_EVENT_AP_STACONNECTED)
//     //    wifi_event_ap_staconnected_t
//     //  case WIFI_EVENT_AP_STADISCONNECTED (SYSTEM_EVENT_AP_STADISCONNECTED)
//     //    wifi_event_ap_stadisconnected_t
//     //  case WIFI_EVENT_AP_PROBEREQRECVED (SYSTEM_EVENT_AP_PROBEREQRECVED)

//   case WIFI_EVENT_STA_CONNECTED:{
//       wifi_event_sta_connected_t *event = (wifi_event_sta_connected_t *) event_data;


//       ESP_LOGI (TAG, "Connected to %s (BSSID: " MACSTR ", Channel: %d)", event->ssid, MAC2STR (event->bssid), event->channel);

//       memcpy (g_ap_bssid, event->bssid, ETH_ALEN);
//       g_ap_channel = event->channel;
//       //        xEventGroupClearBits(wifi_event_group, DISCONNECTED_BIT);
//       //        xEventGroupSetBits(wifi_event_group, CONNECTED_BIT);
//     }
//     break;
//   case WIFI_EVENT_STA_DISCONNECTED:
//     if (s_reconnect && ++s_retry_num < MAX_CONNECT_RETRY_ATTEMPTS) {
//       ESP_LOGI (TAG, "sta disconnect, retry attempt %d...", s_retry_num);
//       esp_wifi_connect ();
//     } else {
//       ESP_LOGI (TAG, "sta disconnected");
//     }
//     //      xEventGroupClearBits(wifi_event_group, CONNECTED_BIT);
//     //      xEventGroupSetBits(wifi_event_group, DISCONNECTED_BIT);
//     break;
//   case WIFI_EVENT_FTM_REPORT:
//     {
//       wifi_event_ftm_report_t *event = (wifi_event_ftm_report_t *) event_data;

//       if (event->status == FTM_STATUS_SUCCESS) {
//      //             g_rtt_est = event->rtt_est;
//      //             g_dist_est = event->dist_est;
//      //             g_ftm_report = event->ftm_report_data;
//      //             g_ftm_report_num_entries = event->ftm_report_num_entries;
//      //             xEventGroupSetBits(ftm_event_group, FTM_REPORT_BIT);
//       } else {
//      ESP_LOGI (TAG, "FTM procedure with Peer(" MACSTR ") failed! (Status - %d)", MAC2STR (event->peer_mac), event->status);
//      //            xEventGroupSetBits(ftm_event_group, FTM_FAILURE_BIT);
//       }
//     }
//     break;
//   case WIFI_EVENT_AP_START:
//     g_ap_started = true;
//     break;
//   case WIFI_EVENT_AP_STOP:
//     g_ap_started = false;
//     break;
//   case WIFI_EVENT_STA_START:
//     g_st_started = true;
//     break;
//   case WIFI_EVENT_STA_STOP:
//     g_st_started = false;
//     break;

//   }
// }

static void
readNVmemoryUnsignedByte (nvs_handle_t my_handle, const char *tag, uint8_t * i2c)
{
  esp_err_t err;

  // Read
    ESP_LOGI (TAG, "Reading %s from NVS ... ", tag);
  int32_t var = 0;		// value will default to 0, if not set yet in NVS
  err = nvs_get_i32 (my_handle, tag, &var);
  switch (err) {
  case ESP_OK:
      ESP_LOGI (TAG, "Done");
      ESP_LOGI (TAG, "%s = %d", tag, var);
    *i2c = var;
    break;
  case ESP_ERR_NVS_NOT_FOUND:
   ESP_LOGI (TAG,    "The value is not initialized yet!");
    err = nvs_set_i32 (my_handle, tag, *i2c);
    printf ((err != ESP_OK) ? "Failed!\n" : "Done\n");
    break;
  default:
    printf ("Error (%s) reading!\n", esp_err_to_name (err));
  }
}

void
readNVmemory (void)
{
  // Initialize NVS


  esp_err_t err = nvs_flash_init ();
  if (err == ESP_ERR_NVS_NO_FREE_PAGES || err == ESP_ERR_NVS_NEW_VERSION_FOUND) {
    // NVS partition was truncated and needs to be erased
    // Retry nvs_flash_init
    ESP_ERROR_CHECK (nvs_flash_erase ());
    err = nvs_flash_init ();
  }

#ifdef ARDVARK_ERASE_FLASH
    ESP_ERROR_CHECK (nvs_flash_erase ());

#endif    
    
  // Open
  
   ESP_LOGI (TAG, "Opening Non-Volatile Storage (NVS) handle... ");
  nvs_handle_t my_handle;
  err = nvs_open ("storage", NVS_READWRITE, &my_handle);
  if (err != ESP_OK) {
     ESP_LOGI (TAG, "Error (%s) opening NVS handle!", esp_err_to_name (err));
  } else {
    int32_t restart_counter = 0;
     ESP_LOGI (TAG, "Done");
   
   
    readNVmemoryUnsignedByte (my_handle, "restart_counter",(uint8_t *) &restart_counter);
    readNVmemoryUnsignedByte (my_handle, "i2c_gpio_scl", &i2c_gpio_scl);
    readNVmemoryUnsignedByte (my_handle, "i2c_gpio_sda", &i2c_gpio_sda);

    printf ("read ports %d %d %d\n", i2c_gpio_sda, i2c_gpio_scl, restart_counter);
    err = nvs_set_i32 (my_handle, "restart_counter", ++restart_counter);
    printf ((err != ESP_OK) ? "Failed!\n" : "Done\n");


     ESP_LOGI (TAG,"Committing updates in NVS ... ");
    err = nvs_commit (my_handle);
    printf ((err != ESP_OK) ? "Failed!\n" : "Done\n");

    // Close
    nvs_close (my_handle);
  }


}

void
app_main ()
{
  readNVmemory  ();

  initialise_wifi ();


#if CONFIG_WIFI_CONNECT_AP
  ESP_LOGW (TAG, "Start AP Mode");
  wifi_ap ();
#elif CONFIG_WIFI_CONNECT_STA
  ESP_LOGW (TAG, "Start STA Mode");
  wifi_sta (CONFIG_STA_CONNECT_TIMEOUT * 1000);
#elif CONFIG_WIFI_CONNECT_APSTA
  ESP_LOGW (TAG, "Start APSTA Mode");
  wifi_apsta (CONFIG_STA_CONNECT_TIMEOUT * 1000);
#endif


#ifdef CONFIG_AARDVARK_VERBOSE
  cJSON *response = wifi_scan ();

  printf ("%s\n", cJSON_Print (response));



response= cJSON_Parse("[17, 76,3 ,4,5,6,7,211]");
 printf ("%s\n", cJSON_Print (response));
// cJSON_Delete(response);
 response=i2cset(8,0,response);
 printf ("first responcse %s\n", cJSON_Print (response));
cJSON_Delete (response);


response= cJSON_Parse("[17, 76,3 ,4,5,6,7,211]");
 printf ("%s\n", cJSON_Print (response));
// cJSON_Delete(response);
 response=i2cset(8,0x10,response);
 printf ("first responcse %s\n", cJSON_Print (response));
cJSON_Delete (response);


//response= cJSON_Parse("[4 2,3 ]");
// printf ("%s\n", cJSON_Print (response));
// cJSON_Delete(response);
// response=i2cset(9,response);
//   printf ("%s\n", cJSON_Print (response));
//cJSON_Delete (response);



 response= i2cget (8, 0, 0x20);
  printf ("%s\n", cJSON_Print (response));
cJSON_Delete (response);

 response= i2cget (9, 0, 0x20);
  printf ("%s\n", cJSON_Print (response));
cJSON_Delete (response);
#endif

  initialise_mdns();

  //  setup_slg ();
  ESP_ERROR_CHECK (init_fs ());
  ESP_ERROR_CHECK (start_rest_server (CONFIG_EXAMPLE_WEB_MOUNT_POINT));

}
