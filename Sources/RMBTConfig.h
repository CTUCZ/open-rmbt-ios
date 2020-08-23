/*
 * Copyright 2013 appscape gmbh
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

#pragma mark - Fixed test parameters

#define RMBT_TEST_SOCKET_TIMEOUT_S      30.0

#define RMBT_TEST_LOOPMODE_MIN_COUNT            1
#define RMBT_TEST_LOOPMODE_MAX_COUNT            100

// Loop mode will stop automatically after this many seconds:
#define RMBT_TEST_LOOPMODE_MAX_DURATION_S       (48*60*60) // 48 hours

// Minimum/maximum number of minutes that user can choose to wait before next test is started:
#define RMBT_TEST_LOOPMODE_MIN_DELAY_MINS       15
#define RMBT_TEST_LOOPMODE_DEFAULT_DELAY_MINS   30
#define RMBT_TEST_LOOPMODE_MAX_DELAY_MINS       (24 * 60) // one day

// ... meters user locations must change before next test is started:
#define RMBT_TEST_LOOPMODE_MIN_MOVEMENT_M       50
#define RMBT_TEST_LOOPMODE_DEFAULT_MOVEMENT_M   250
#define RMBT_TEST_LOOPMODE_MAX_MOVEMENT_M       10000

// How accurate the location needs to be before it's considered for the movement (less that this value)
#define RMBT_TEST_LOOPMODE_MOVEMENT_MIN_ACCURACY_M 20

#define RMBT_TEST_LOOPMODE_DEFAULT_COUNT        10

#define RMBT_TEST_PRETEST_MIN_CHUNKS_FOR_MULTITHREADED_TEST 4
#define RMBT_TEST_PRETEST_DURATION_S    2.0
#define RMBT_TEST_PING_COUNT            10

// The getaddrinfo() used by GCDAsync socket will fail immediately if the hostname of the test server
// is not in the DNS cache. To work around this, in case of this particular error we will retry couple
// of times before giving up:
#define RMBT_TEST_HOST_LOOKUP_RETRIES   1 // How many times to retry
#define RMBT_TEST_HOST_LOOKUP_WAIT_S    0.2 // How long to wait before next retry

// In case of slow upload, we finalize the test even if this many seconds still haven't been received:
#define RMBT_TEST_UPLOAD_MAX_DISCARD_S  1.0

// Minimum number of seconds to wait after sending last chunk, before starting to discard.
#define RMBT_TEST_UPLOAD_MIN_WAIT_S     0.25

// Maximum number of seconds to wait for server reports after last chunk has been sent.
// After this interval we will close the socket and finish the test on first report received.
#define RMBT_TEST_UPLOAD_MAX_WAIT_S     3

// Measure and submit speed during test in these intervals
#define RMBT_TEST_SAMPLING_RESOLUTION_MS 250

// Timeout for connecting and reading responses back from QoS control server
#define RMBT_QOS_CC_TIMEOUT_S           5.0

#pragma mark - Default control server URLs

#warning Please supply a valid URL for the control server. For setting up your own test server, see https://github.com/alladin-IT/open-rmbt
#define RMBT_CONTROL_SERVER_URL         @"https://sdev.netztest.at/RMBTControlServer"
#define RMBT_CONTROL_SERVER_IPV4_URL    @"https://sdevv4.netztest.at/RMBTControlServer"
#define RMBT_CONTROL_SERVER_IPV6_URL    @"https://sdevv6.netztest.at/RMBTControlServer"

#pragma mark - Other URLs used in the app

// Note: $lang will be replaced by "de" is device language is german, or "en" in any other case:
#define RMBT_PROJECT_URL     @"https://www.netztest.at/"
#define RMBT_PROJECT_EMAIL   @"netztest@rtr.at"
#define RMBT_PRIVACY_TOS_URL @"https://www.netztest.at/redirect/$lang/terms"
#define RMBT_ABOUT_URL       @"https://www.rtr.at/$lang/"

// Note: stats url can can be replaced with the /settings response from control server
#define RMBT_STATS_URL       @"https://www.netztest.at/$lang/Statistik#noMMenu"

#define RMBT_HELP_URL        @"https://www.netztest.at/redirect/$lang/help"

#define RMBT_REPO_URL        @"https://github.com/rtr-nettest/open-rmbt-ios"
#define RMBT_DEVELOPER_URL   @"http://appscape.at/"

#pragma mark - Map options

// Initial map center coordinates and zoom level:
#define RMBT_MAP_INITIAL_LAT        48.20855
#define RMBT_MAP_INITIAL_LNG        16.37312
#define RMBT_MAP_INITIAL_ZOOM       12

// Zoom level to use when showing a test result location
#define RMBT_MAP_POINT_ZOOM         12

// In "auto" mode, when zoomed in past this level, map switches to points
#define RMBT_MAP_AUTO_TRESHOLD_ZOOM 12

// Google Maps API Key

#warning Please supply a valid Google Maps API Key. See https://developers.google.com/maps/documentation/ios/start#the_google_maps_api_key
#define RMBT_GMAPS_API_KEY @"AIzaSyDCoFuxghaMIVOKEeGxeGInAiWo9A0iJL4"

#pragma mark - Misc

// Current TOS version. Bump to force displaying TOS to users again.
#define RMBT_TOS_VERSION 1

#define RMBT_DARK_COLOR ([UIColor rmbt_colorWithRGBHex:0x0e1e34])
#define RMBT_TINT_COLOR ([UIColor rmbt_colorWithRGBHex:0x00abe7])
