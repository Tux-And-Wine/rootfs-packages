#ifndef _ANDROID_IDS
#define _ANDROID_IDS

#include "android_system_user_ids.h"

#define AID_USER_OFFSET 100000
#define AID_OVERFLOWUID 65534
#define AID_ISOLATED_START 99000
#define AID_ISOLATED_END 99999
#define AID_APP_START 10000
#define AID_APP_END 19999
#define AID_CACHE_GID_START 20000
#define AID_CACHE_GID_END 29999
#define AID_EXT_GID_START 30000
#define AID_EXT_GID_END 39999
#define AID_EXT_CACHE_GID_START 40000
#define AID_EXT_CACHE_GID_END 49999
#define AID_SHARED_GID_START 50000
#define AID_SHARED_GID_END 59999

#define AID_OEM_RESERVED_START 2900
#define AID_OEM_RESERVED_END 2999
#define AID_OEM_RESERVED_2_START 5000
#define AID_OEM_RESERVED_2_END 5999

struct IdRange {
    id_t start;
    id_t end;
};

static struct IdRange user_ranges[] = {
    { AID_APP_START, AID_APP_END },
    { AID_ISOLATED_START, AID_ISOLATED_END },
};

static struct IdRange group_ranges[] = {
    { AID_APP_START, AID_APP_END },
    { AID_CACHE_GID_START, AID_CACHE_GID_END },
    { AID_EXT_GID_START, AID_EXT_GID_END },
    { AID_EXT_CACHE_GID_START, AID_EXT_CACHE_GID_END },
    { AID_SHARED_GID_START, AID_SHARED_GID_END },
    { AID_ISOLATED_START, AID_ISOLATED_END },
};

struct android_id_info {
    const char *name;
    unsigned aid;
};

static struct android_id_info android_ids[] = {
    { "root", AID_ROOT, },
    { "daemon", AID_DAEMON, },
    { "bin", AID_BIN, },
    { "sys", AID_SYS, },
    { "system", AID_SYSTEM, },
    { "radio", AID_RADIO, },
    { "bluetooth", AID_BLUETOOTH, },
    { "graphics", AID_GRAPHICS, },
    { "input", AID_INPUT, },
    { "audio", AID_AUDIO, },
    { "camera", AID_CAMERA, },
    { "log", AID_LOG, },
    { "compass", AID_COMPASS, },
    { "mount", AID_MOUNT, },
    { "wifi", AID_WIFI, },
    { "adb", AID_ADB, },
    { "install", AID_INSTALL, },
    { "media", AID_MEDIA, },
    { "dhcp", AID_DHCP, },
    { "sdcard_rw", AID_SDCARD_RW, },
    { "vpn", AID_VPN, },
    { "keystore", AID_KEYSTORE, },
    { "usb", AID_USB, },
    { "drm", AID_DRM, },
    { "mdnsr", AID_MDNSR, },
    { "gps", AID_GPS, },
    { "unused1", AID_UNUSED1, },
    { "media_rw", AID_MEDIA_RW, },
    { "mtp", AID_MTP, },
    { "unused2", AID_UNUSED2, },
    { "drmrpc", AID_DRMRPC, },
    { "nfc", AID_NFC, },
    { "sdcard_r", AID_SDCARD_R, },
    { "clat", AID_CLAT, },
    { "loop_radio", AID_LOOP_RADIO, },
    { "media_drm", AID_MEDIA_DRM, },
    { "package_info", AID_PACKAGE_INFO, },
    { "sdcard_pics", AID_SDCARD_PICS, },
    { "sdcard_av", AID_SDCARD_AV, },
    { "sdcard_all", AID_SDCARD_ALL, },
    { "logd", AID_LOGD, },
    { "shared_relro", AID_SHARED_RELRO, },
    { "dbus", AID_DBUS, },
    { "tlsdate", AID_TLSDATE, },
    { "media_ex", AID_MEDIA_EX, },
    { "audioserver", AID_AUDIOSERVER, },
    { "metrics_coll", AID_METRICS_COLL, },
    { "metricsd", AID_METRICSD, },
    { "webserv", AID_WEBSERV, },
    { "debuggerd", AID_DEBUGGERD, },
    { "media_codec", AID_MEDIA_CODEC, },
    { "cameraserver", AID_CAMERASERVER, },
    { "firewall", AID_FIREWALL, },
    { "trunks", AID_TRUNKS, },
    { "nvram", AID_NVRAM, },
    { "dns", AID_DNS, },
    { "dns_tether", AID_DNS_TETHER, },
    { "webview_zygote", AID_WEBVIEW_ZYGOTE, },
    { "vehicle_network", AID_VEHICLE_NETWORK, },
    { "media_audio", AID_MEDIA_AUDIO, },
    { "media_video", AID_MEDIA_VIDEO, },
    { "media_image", AID_MEDIA_IMAGE, },
    { "tombstoned", AID_TOMBSTONED, },
    { "media_obb", AID_MEDIA_OBB, },
    { "ese", AID_ESE, },
    { "ota_update", AID_OTA_UPDATE, },
    { "automotive_evs", AID_AUTOMOTIVE_EVS, },
    { "lowpan", AID_LOWPAN, },
    { "hsm", AID_HSM, },
    { "reserved_disk", AID_RESERVED_DISK, },
    { "statsd", AID_STATSD, },
    { "incidentd", AID_INCIDENTD, },
    { "secure_element", AID_SECURE_ELEMENT, },
    { "lmkd", AID_LMKD, },
    { "llkd", AID_LLKD, },
    { "iorapd", AID_IORAPD, },
    { "gpu_service", AID_GPU_SERVICE, },
    { "network_stack", AID_NETWORK_STACK, },
    { "gsid", AID_GSID, },
    { "fsverity_cert", AID_FSVERITY_CERT, },
    { "credstore", AID_CREDSTORE, },
    { "external_storage", AID_EXTERNAL_STORAGE, },
    { "ext_data_rw", AID_EXT_DATA_RW, },
    { "ext_obb_rw", AID_EXT_OBB_RW, },
    { "context_hub", AID_CONTEXT_HUB, },
    { "virtualizationservice", AID_VIRTUALIZATIONSERVICE, },
    { "artd", AID_ARTD, },
    { "uwb", AID_UWB, },
    { "thread_network", AID_THREAD_NETWORK, },
    { "diced", AID_DICED, },
    { "dmesgd", AID_DMESGD, },
    { "jc_weaver", AID_JC_WEAVER, },
    { "jc_strongbox", AID_JC_STRONGBOX, },
    { "jc_identitycred", AID_JC_IDENTITYCRED, },
    { "sdk_sandbox", AID_SDK_SANDBOX, },
    { "security_log_writer", AID_SECURITY_LOG_WRITER, },
    { "prng_seeder", AID_PRNG_SEEDER, },
    { "shell", AID_SHELL, },
    { "cache", AID_CACHE, },
    { "diag", AID_DIAG, },
    { "net_bt_admin", AID_NET_BT_ADMIN, },
    { "net_bt", AID_NET_BT, },
    { "inet", AID_INET, },
    { "net_raw", AID_NET_RAW, },
    { "net_admin", AID_NET_ADMIN, },
    { "net_bw_stats", AID_NET_BW_STATS, },
    { "net_bw_acct", AID_NET_BW_ACCT, },
    { "readproc", AID_READPROC, },
    { "wakelock", AID_WAKELOCK, },
    { "uhid", AID_UHID, },
    { "readtracefs", AID_READTRACEFS, },
    { "everybody", AID_EVERYBODY, },
    { "misc", AID_MISC, },
    { "nobody", AID_NOBODY, },
};

#define android_id_count (sizeof(android_ids) / sizeof(android_ids[0]))

// default paths for the application
#define APP_HOME_DIR "/opt/glibc-packages/home"
#define APP_PREFIX_DIR "/opt/glibc-packages/usr"

#endif // _ANDROID_IDS
