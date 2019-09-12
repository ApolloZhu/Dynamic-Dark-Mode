//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "TouchBarPrivateAPI.h"

// MARK: - Skylight

BOOL SLSGetAppearanceThemeLegacy();
void SLSSetAppearanceThemeLegacy(BOOL);
BOOL SLSGetAppearanceThemeSwitchesAutomatically() API_AVAILABLE(macosx(10.15));
void SLSSetAppearanceThemeSwitchesAutomatically(BOOL) API_AVAILABLE(macosx(10.15));
