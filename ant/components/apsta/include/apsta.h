

void event_handler(void* arg, esp_event_base_t event_base,
								int32_t event_id, void* event_data);
void initialise_wifi(void);

#if CONFIG_WIFI_CONNECT_AP
bool wifi_ap(void);
#endif

#if CONFIG_WIFI_CONNECT_STA
bool wifi_sta(int timeout_ms);
#endif

#if CONFIG_WIFI_CONNECT_APSTA
bool wifi_apsta(int timeout_ms);
#endif