import           Control.Monad              (join, when)
import qualified Data.Map                   as M
import           Data.Maybe                 (maybeToList)
import           System.Exit
import           System.IO
import           XMonad
import           XMonad.Hooks.EwmhDesktops  (ewmh, fullscreenEventHook)
import           XMonad.Hooks.ICCCMFocus    (takeTopFocus)
import           XMonad.Hooks.ManageDocks   (ToggleStruts (..), avoidStruts,
                                             docks, manageDocks)
import           XMonad.Hooks.ManageHelpers (isDialog)
import           XMonad.Layout.NoBorders    (noBorders)
import           XMonad.Layout.Spacing      (smartSpacing, smartSpacingWithEdge,
                                             spacing, spacingWithEdge)
import           XMonad.Operations
import           XMonad.Util.EZConfig
import           XMonad.Util.Run            (spawnPipe)


myTerminal = "kitty"

myLayouts = (avoidStruts . spacingWithEdge 8) (tiled ||| Mirror tiled ||| Full)
            ||| noBorders Full
  where
     tiled   = Tall nmaster delta ratio -- default tiling algorithm partitions the screen into two panes
     nmaster = 1                        -- The default number of windows in the master pane
     ratio   = 1/2                      -- Default proportion of screen occupied by master pane
     delta   = 3/100                    -- Percent of screen to increment by when resizing panes

myKeys conf@(XConfig {XMonad.modMask = modMask}) = M.fromList $
    [ ((modMask, xK_q), kill)
    , ((modMask, xK_b), sendMessage ToggleStruts)
    , ((modMask, xK_f), spawn "env MOZ_USE_XINPUT2=1 firefox")
    , ((modMask, xK_x), spawn myTerminal)
    , ((modMask .|. shiftMask, xK_q), restart "xmonad" True)
    , ((modMask .|. shiftMask .|. controlMask, xK_q), io (exitWith ExitSuccess) )
    ]

myManageHook = composeAll . concat $
  [ [ isDialog --> doFloat ]
  , [ className =? cls --> doFloat | cls <- myCFloats ]
  ] where myCFloats = [ ]

main = xmonad . ewmh $ docks baseConf -- docks is needed so xmonad doesn't cover xmobar
              { terminal   = myTerminal
              , manageHook = myManageHook <+> manageDocks <+> manageHook baseConf
              , modMask    = mod4Mask
              , keys       = myKeys <+> keys baseConf
              , layoutHook = myLayouts
              , handleEventHook = fullscreenEventHook
              --, startupHook = startupHook def >> addEWMHFullscreen
              , focusedBorderColor = "#fbf1c7"
              , normalBorderColor = "#f2e5bc"
              , borderWidth = 3
              , logHook = logHook baseConf >> takeTopFocus
              }
       where baseConf = def

-- This works, but the border with fullscreen is still a problem
-- Fix for fullscreen
addNETSupported :: Atom -> X ()
addNETSupported x = withDisplay $ \dpy -> do
  r               <- asks theRoot
  a_NET_SUPPORTED <- getAtom "_NET_SUPPORTED"
  a               <- getAtom "ATOM"
  liftIO $ do
    sup <- (join . maybeToList) <$> getWindowProperty32 dpy a_NET_SUPPORTED r
    when (fromIntegral x `notElem` sup) $
      changeProperty32 dpy r a_NET_SUPPORTED a propModeAppend [fromIntegral x]

addEWMHFullscreen :: X ()
addEWMHFullscreen   = do
  wms <- getAtom "_NET_WM_STATE"
  wfs <- getAtom "_NET_WM_STATE_FULLSCREEN"
  mapM_ addNETSupported [wms, wfs]

