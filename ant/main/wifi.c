#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "esp_wifi.h"
#include "esp_log.h"
#include "esp_event.h"
#include "nvs_flash.h"
#include "cJSON.h"

#define DEFAULT_SCAN_LIST_SIZE CONFIG_EXAMPLE_SCAN_LIST_SIZE
static cJSON *response;

static const char *TAG = "scan";

static const char *
print_auth_mode (int authmode)
{
  switch (authmode) {
  case WIFI_AUTH_OPEN:
    return "OPEN";
    break;
  case WIFI_AUTH_WEP:
    return "WEP";
    break;
  case WIFI_AUTH_WPA_PSK:
    return "WPA PSK";
    break;
  case WIFI_AUTH_WPA2_PSK:
    return "WPA2 PSK";
    break;
  case WIFI_AUTH_WPA_WPA2_PSK:
    return "WPA WPA2 PSK";
    break;
  case WIFI_AUTH_WPA2_ENTERPRISE:
    return "WPA2 ENTERPRISE";
    break;
  case WIFI_AUTH_WPA3_PSK:
    return "WPA3 PSK";
    break;
  case WIFI_AUTH_WPA2_WPA3_PSK:
    return "WPA2 WPA3 PSK";
    break;
  default:
    return "UNKNOWN";
    break;
  }
}

static const char *
print_pairwise_cipher (int pairwise_cipher)
{
  switch (pairwise_cipher) {
  case WIFI_CIPHER_TYPE_NONE:
    return "NONE";
    break;
  case WIFI_CIPHER_TYPE_WEP40:
    return "WEP40";
    break;
  case WIFI_CIPHER_TYPE_WEP104:
    return "WEP104";
    break;
  case WIFI_CIPHER_TYPE_TKIP:
    return "TKIP";
    break;
  case WIFI_CIPHER_TYPE_CCMP:
    return "CCMP";
    break;
  case WIFI_CIPHER_TYPE_TKIP_CCMP:
    return "TKIP CCMP";
    break;
  default:
    return "UNKNOWN";
    break;
  }
}

static const char *
print_group_cipher (int group_cipher)
{

  switch (group_cipher) {
  case WIFI_CIPHER_TYPE_NONE:
    return "NONE";
    break;
  case WIFI_CIPHER_TYPE_WEP40:
    return "WEP40";
    break;
  case WIFI_CIPHER_TYPE_WEP104:
    return "WEP104";
    break;
  case WIFI_CIPHER_TYPE_TKIP:
    return "TKIP";
    break;
  case WIFI_CIPHER_TYPE_CCMP:
    return "CCMP";
    break;
  case WIFI_CIPHER_TYPE_TKIP_CCMP:
    return "TKIP CCMP";
    break;
  default:
    return "UNKNOWN";
    break;
  }
}


cJSON *
wifi_scan (void)
{
  uint16_t number = DEFAULT_SCAN_LIST_SIZE;
  wifi_ap_record_t ap_info[DEFAULT_SCAN_LIST_SIZE];
  uint16_t ap_count = 0;
  memset (ap_info, 0, sizeof (ap_info));
  response = cJSON_CreateArray ();

  esp_wifi_scan_start (NULL, true);
  ESP_ERROR_CHECK (esp_wifi_scan_get_ap_records (&number, ap_info));
  ESP_ERROR_CHECK (esp_wifi_scan_get_ap_num (&ap_count));
  ESP_LOGI (TAG, "Total APs scanned = %u", ap_count);

  for (int i = 0; (i < DEFAULT_SCAN_LIST_SIZE) && (i < ap_count); i++) {

    cJSON *x_json = cJSON_CreateObject ();
    cJSON_AddItemToArray (response, x_json);
    cJSON_AddStringToObject (x_json, "SSID", (char *) ap_info[i].ssid);
    cJSON_AddNumberToObject (x_json, "RSSI", ap_info[i].rssi);
    cJSON_AddNumberToObject (x_json, "Channel", ap_info[i].primary);
    cJSON_AddStringToObject (x_json, "Authmode", print_auth_mode (ap_info[i].authmode));


    ESP_LOGI (TAG, "SSID \t\t%s", ap_info[i].ssid);
    ESP_LOGI (TAG, "RSSI \t\t%d", ap_info[i].rssi);


    ESP_LOGI (TAG, "Authmode \t%s", print_auth_mode (ap_info[i].authmode));
    if (ap_info[i].authmode != WIFI_AUTH_WEP) {
      ESP_LOGI (TAG, "Pairwise Cipher \t%s", print_pairwise_cipher (ap_info[i].pairwise_cipher));
      ESP_LOGI (TAG, "Group_Cipher \t%s", print_group_cipher (ap_info[i].group_cipher));

      cJSON_AddStringToObject (x_json, "Pairwise Cipher", print_pairwise_cipher (ap_info[i].pairwise_cipher));
      cJSON_AddStringToObject (x_json, "Group_Cipher", print_group_cipher (ap_info[i].group_cipher));

    }
    ESP_LOGI (TAG, "Channel \t\t%d\n", ap_info[i].primary);
  }

  return response;
}
