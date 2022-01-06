{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;

    profiles.main-profile = {
      isDefault = true;
      name = "main-profile";

      settings = {
        "browser.search.widget.inNavBar" = true;
        "datareporting.policy.dataSubmissionPolicyAcceptedVersion" = 2;
        "media.videocontrols.picture-in-picture.allow-multiple" = false;
        "media.videocontrols.picture-in-picture.enabled" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };

      userChrome = ''
        @namespace url("http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul");

        /* Recreates the basic functionality of the popular Roomy Bookmarks Toolbar add-on:
        Hide bookamrks bar items label text, show on hover. */

        .bookmark-item {
          height: 16px !important;
          margin: -2px 0 !important;
          padding: 0 2px !important;
        }
        .bookmark-item > .toolbarbutton-text {
          margin-top: -1px !important;
        }
        .bookmark-item:not(:hover):not([open="true"]) > .toolbarbutton-text {
          display: none !important;
        }
        .bookmark-item > .toolbarbutton-icon {
          height: 16px !important;
          width: 16px !important;
          margin: -2px 0 -2px 0 !important;
          padding: 0px !important;
        }
        #PlacesToolbarItems > .bookmark-item:not(:hover):not([open="true"]) > .toolbarbutton-icon[label]:not([label=""])     {
          margin-inline-end: 0px !important;
        }
      '';
    };
  };
}
