    -- Base
import XMonad
import System.Directory
import System.IO (hClose, hPutStr, hPutStrLn)
import System.Process (callCommand)
import System.Exit (exitSuccess)
import qualified XMonad.StackSet as W

    -- Actions
import XMonad.Actions.CopyWindow (kill1)
import XMonad.Actions.CycleWS (Direction1D(..), moveTo, shiftTo, WSType(..), nextScreen, prevScreen)
import XMonad.Actions.GridSelect
import XMonad.Actions.MouseResize
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotSlavesDown, rotAllDown)
import XMonad.Actions.WindowGo (runOrRaise)
import XMonad.Actions.WithAll (sinkAll, killAll)
import qualified XMonad.Actions.Search as S

    -- Data
import Data.Char (isSpace, toUpper)
import Data.Maybe (fromJust)
import Data.Monoid
import Data.Maybe (isJust)
import Data.Tree
import qualified Data.Map as M

    -- Hooks
import XMonad.Hooks.DynamicLog (dynamicLogWithPP, wrap, xmobarPP, xmobarColor, shorten, PP(..))
import XMonad.Hooks.EwmhDesktops  -- for some fullscreen events, also for xcomposite in obs.
import XMonad.Hooks.ManageDocks (avoidStruts, docks, manageDocks, ToggleStruts(..))
import XMonad.Hooks.ManageHelpers (isFullscreen, doFullFloat, doCenterFloat)
import XMonad.Hooks.ServerMode
import XMonad.Hooks.SetWMName
import XMonad.Hooks.StatusBar
import XMonad.Hooks.StatusBar.PP
import XMonad.Hooks.WindowSwallowing
import XMonad.Hooks.WorkspaceHistory

    -- Layouts
import XMonad.Layout.GridVariants (Grid(Grid))
import XMonad.Layout.SimplestFloat
import XMonad.Layout.ResizableTile
import XMonad.Layout.Tabbed


-- Layouts modifiers
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows, increaseLimit, decreaseLimit)
import XMonad.Layout.MultiToggle (mkToggle, single, EOT(EOT), (??))
import XMonad.Layout.MultiToggle.Instances (StdTransformers(NBFULL, MIRROR, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.Renamed
import XMonad.Layout.ShowWName
import XMonad.Layout.Simplest
import XMonad.Layout.Spacing
import XMonad.Layout.SubLayouts
import XMonad.Layout.WindowArranger (windowArrange, WindowArrangerMsg(..))
import XMonad.Layout.WindowNavigation
import qualified XMonad.Layout.ToggleLayouts as T (toggleLayouts, ToggleLayout(Toggle))
import qualified XMonad.Layout.MultiToggle as MT (Toggle(..))

-- Utilities
import XMonad.Util.Dmenu
import XMonad.Util.EZConfig (additionalKeysP, mkNamedKeymap)
import XMonad.Util.Hacks (windowedFullscreenFixEventHook, javaHack, trayerAboveXmobarEventHook, trayAbovePanelEventHook, trayerPaddingXmobarEventHook, trayPaddingXmobarEventHook, trayPaddingEventHook)
import XMonad.Util.NamedActions as NamedActions
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (runProcessWithInput, safeSpawn, spawnPipe)
import XMonad.Util.SpawnOnce

-- Battery periodic check (TEST)
import Control.Concurrent (forkIO, threadDelay)
--import Control.Monad (forever, when, void)
-- Right handed master pane test
import XMonad.Layout.Reflect

-- Doom One color scheme
colorScheme = "doom-one"
colorBack = "#282c34"
colorFore = "#bbc2cf"
color01 = "#1c1f24"
color02 = "#ff6c6b"
color03 = "#98be65"
color04 = "#da8548"
color05 = "#51afef"
color06 = "#c678dd"
color07 = "#5699af"
color08 = "#202328"
color09 = "#5b6268"
color10 = "#da8548"
color11 = "#4db5bd"
color12 = "#ecbe7b"
color13 = "#3071db"
color14 = "#a9a1e1"
color15 = "#46d9ff"
color16 = "#dfdfdf"


myFont :: String
myFont = "xft:SauceCodePro Nerd Font Mono:regular:size=9:antialias=true:hinting=true"

myModMask :: KeyMask
myModMask = mod4Mask

myTerminal :: String
myTerminal = "alacritty"

myBrowser :: String
myBrowser = "zen-browser"

myEditor :: String
myEditor = myTerminal ++ " -e vim "

myBorderWidth :: Dimension
myBorderWidth = 2

myNormColor :: String
myNormColor   = colorBack

myFocusColor :: String    
myFocusColor  = color15

mySoundPlayer :: String
mySoundPlayer = "ffplay -nodisp -autoexit " 

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


myStartupHook = do
    -- Kill any previous instances
    safeSpawn "killall" ["conky"]
    safeSpawn "killall" ["blueman-applet"]
    safeSpawn "killall" ["trayer"]

    liftIO $ threadDelay (2 * 1000000)

    safeSpawn "trayer" ["--edge", "top", "--align", "right", "--widthtype", "request", "--padding", "4", "--SetDockType", "true", "--SetPartialStrut", "false", "--expand", "true", "--transparent", "true", "--alpha", "0", "--tint", "0x282c34", "--height", "22", "--monitor", "primary"]
    spawn $ "bluetoothctl info | grep -q 'Connected: yes' && blueman-applet"
    safeSpawn "unclutter" ["-idle", "1"]
    safeSpawn "dunst" []
    safeSpawn "batsignal" ["-w", "30", "-c", "20", "-d", "10", "-f", "89"]
    safeSpawn "conky" ["-c", "/home/devid/.config/conky/doom-one-01.conkyrc"]

    -- Launch system control applications

    -- Run startup utilities
    spawnOnce "$HOME/.local/bin/x-settings"
    spawnOnce "numlockx"
    spawnOnce "feh --bg-fill $HOME/pictures/wallpapers/kde6Pata-dark.png"
    --spawn "if ! mountpoint -q $HOME/password-store; then alacritty -e $HOME/.local/bin/mount-password-store; fi"
    spawnOnce "sudo tlp start"
    


myNavigation :: TwoD a (Maybe a)
myNavigation = makeXEventhandler $ shadowWithKeymap navKeyMap navDefaultHandler
 where navKeyMap = M.fromList [
          ((0,xK_Escape), cancel)
         ,((0,xK_Return), select)
         ,((0,xK_slash) , substringSearch myNavigation)
         ,((0,xK_Left)  , move (-1,0)  >> myNavigation)
         ,((0,xK_h)     , move (-1,0)  >> myNavigation)
         ,((0,xK_Right) , move (1,0)   >> myNavigation)
         ,((0,xK_l)     , move (1,0)   >> myNavigation)
         ,((0,xK_Down)  , move (0,1)   >> myNavigation)
         ,((0,xK_k)     , move (0,1)   >> myNavigation)
         ,((0,xK_Up)    , move (0,-1)  >> myNavigation)
         ,((0,xK_j)     , move (0,-1)  >> myNavigation)
         ,((0,xK_y)     , move (-1,-1) >> myNavigation)
         ,((0,xK_i)     , move (1,-1)  >> myNavigation)
         ,((0,xK_n)     , move (-1,1)  >> myNavigation)
         ,((0,xK_m)     , move (1,-1)  >> myNavigation)
         ,((0,xK_space) , setPos (0,0) >> myNavigation)
         ]
       navDefaultHandler = const myNavigation

myColorizer :: Window -> Bool -> X (String, String)
myColorizer = colorRangeFromClassName
                (0x28,0x2c,0x34) -- lowest inactive bg
                (0x28,0x2c,0x34) -- highest inactive bg
                (0xc7,0x92,0xea) -- active bg
                (0xc0,0xa7,0x9a) -- inactive fg
                (0x28,0x2c,0x34) -- active fg

-- gridSelect menu layout
mygridConfig :: p -> GSConfig Window
mygridConfig colorizer = (buildDefaultGSConfig myColorizer)
    { gs_cellheight   = 40
    , gs_cellwidth    = 200
    , gs_cellpadding  = 6
    , gs_navigate    = myNavigation
    , gs_originFractX = 0.5
    , gs_originFractY = 0.5
    , gs_font         = myFont
    }

spawnSelected' :: [(String, String)] -> X ()
spawnSelected' lst = gridselect conf lst >>= flip whenJust spawn
    where conf = def
                   { gs_cellheight   = 40
                   , gs_cellwidth    = 180
                   , gs_cellpadding  = 6
                   , gs_originFractX = 0.5
                   , gs_originFractY = 0.5
                   , gs_font         = myFont
                   }

runSelectedAction' :: GSConfig (X ()) -> [(String, X ())] -> X ()
runSelectedAction' conf actions = do
    selectedActionM <- gridselect conf actions
    case selectedActionM of
        Just selectedAction -> selectedAction
        Nothing -> return ()

-- gsCategories =
--   [ ("Games",      spawnSelected' gsGames)
--   , ("Education",   spawnSelected' gsEducation)
--   , ("Internet",   spawnSelected' gsInternet)
--   , ("Multimedia", spawnSelected' gsMultimedia)
--   , ("Office",     spawnSelected' gsOffice)
--   , ("Settings",   spawnSelected' gsSettings)
--   , ("System",     spawnSelected' gsSystem)
--   , ("Utilities",  spawnSelected' gsUtilities)
--   ]

gsCategories =
  [ ("Games",      "xdotool key super+alt+1")
  , ("Education",  "xdotool key super+alt+2")
  , ("Internet",   "xdotool key super+alt+3")
  , ("Multimedia", "xdotool key super+alt+4")
  , ("Office",     "xdotool key super+alt+5")
  , ("Settings",   "xdotool key super+alt+6")
  , ("System",     "xdotool key super+alt+7")
  , ("Utilities",  "xdotool key super+alt+8")
  ]

gsGames =
  [ ("0 A.D.", "0ad")
  , ("Battle For Wesnoth", "wesnoth")
  , ("OpenArena", "openarena")
  , ("Sauerbraten", "sauerbraten")
  , ("Steam", "steam")
  , ("Unvanquished", "unvanquished")
  , ("Xonotic", "xonotic-glx")
  ]

gsEducation =
  [ ("GCompris", "gcompris-qt")
  , ("Kstars", "kstars")
  , ("Minuet", "minuet")
  , ("Scratch", "scratch")
  ]

gsInternet =
  [ ("Zen", "zen-browser")
  , ("Discord", "discord")
  , ("Element", "element-desktop")
  , ("Firefox", "firefox")
  , ("LBRY App", "lbry")
  , ("Mailspring", "mailspring")
  , ("Nextcloud", "nextcloud")
  , ("Brave", "brave")
  , ("Transmission", "transmission-gtk")
  , ("Zoom", "zoom")
  ]

gsMultimedia =
  [ ("Audacity", "audacity")
  , ("Blender", "blender")
  , ("Deadbeef", "deadbeef")
  , ("Kdenlive", "kdenlive")
  , ("OBS Studio", "obs")
  , ("VLC", "vlc")
  ]

gsOffice =
  [ ("Document Viewer", "evince")
  , ("LibreOffice", "libreoffice")
  , ("LO Base", "lobase")
  , ("LO Calc", "localc")
  , ("LO Draw", "lodraw")
  , ("LO Impress", "loimpress")
  , ("LO Math", "lomath")
  , ("LO Writer", "lowriter")
  ]

gsSettings =
  [ ("ARandR", "arandr")
  , ("ArchLinux Tweak Tool", "archlinux-tweak-tool")
  , ("Customize Look and Feel", "lxappearance")
  , ("Firewall Configuration", "sudo gufw")
  ]

gsSystem =
  [ ("Alacritty", "alacritty")
  , ("Bash", (myTerminal ++ " -e bash"))
  , ("Htop", (myTerminal ++ " -e htop"))
  , ("Fish", (myTerminal ++ " -e fish"))
  , ("PCManFM", "pcmanfm")
  , ("VirtualBox", "virtualbox")
  , ("Virt-Manager", "virt-manager")
  , ("Zsh", (myTerminal ++ " -e zsh"))
  ]

gsUtilities =
  [ ("Emacs", "emacs")
  , ("Emacsclient", "emacsclient -c -a '' --eval '(progn (+doom-dashboard/open (selected-frame)))'")
  , ("Nitrogen", "nitrogen")
  , ("Vim", (myTerminal ++ " -e vim"))
  ]

myScratchPads :: [NamedScratchpad]
myScratchPads = [ NS "terminal" spawnTerm findTerm manageTerm
                , NS "mocp" spawnMocp findMocp manageMocp
                , NS "calculator" spawnCalc findCalc manageCalc
                ]
  where
    spawnTerm  = myTerminal ++ " -t scratchpad"
    findTerm   = title =? "scratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnMocp  = myTerminal ++ " -t mocp -e mocp"
    findMocp   = title =? "mocp"
    manageMocp = customFloating $ W.RationalRect l t w h
               where
                 h = 0.9
                 w = 0.9
                 t = 0.95 -h
                 l = 0.95 -w
    spawnCalc  = "qalculate-gtk"
    findCalc   = className =? "Qalculate-gtk"
    manageCalc = customFloating $ W.RationalRect l t w h
               where
                 h = 0.5
                 w = 0.4
                 t = 0.75 -h
                 l = 0.70 -w

--Makes setting the spacingRaw simpler to write. The spacingRaw module adds a configurable amount of space around windows.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw False (Border i i i i) True (Border i i i i) True

-- Below is a variation of the above except no borders are applied
-- if fewer than two windows. So a single window has no gaps.
mySpacing' :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing' i = spacingRaw True (Border i i i i) True (Border i i i i) True

-- Defining a bunch of layouts, many that I don't use.
-- limitWindows n sets maximum number of windows displayed for layout.
-- mySpacing n sets the gap size around the windows.
tall     = renamed [Replace "tall"]
           $ limitWindows 5
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 2
           $ reflectHoriz                           -- Right handed master pane
           $ ResizableTall 1 (3/100) (1/2) []
monocle  = renamed [Replace "monocle"]
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ avoidStruts 
           $ Full
floats   = renamed [Replace "floats"]
           $ smartBorders
           $ simplestFloat
grid     = renamed [Replace "grid"]
           $ limitWindows 9
           $ smartBorders
           $ windowNavigation
           $ addTabs shrinkText myTabTheme
           $ subLayout [] (smartBorders Simplest)
           $ mySpacing 8
           $ mkToggle (single MIRROR)
           $ Grid (16/10)
tabs     = renamed [Replace "tabs"]
           $ tabbed shrinkText myTabTheme

-- setting colors for tabs layout and tabs sublayout.
myTabTheme = def { fontName            = myFont
                 , activeColor         = color15
                 , inactiveColor       = color08
                 , activeBorderColor   = color15
                 , inactiveBorderColor = colorBack
                 , activeTextColor     = colorBack
                 , inactiveTextColor   = color16
                 }


-- Theme for showWName which prints current workspace when you change workspaces.
myShowWNameTheme :: SWNConfig
myShowWNameTheme = def
  { swn_font              = "xft:Ubuntu:bold:size=60"
  , swn_fade              = 1.0
  , swn_bgcolor           = "#1c1f24"
  , swn_color             = "#ffffff"
  }

-- The layout hook
myLayoutHook = avoidStruts
               $ mouseResize
               $ windowArrange
               $ T.toggleLayouts (noBorders Full)
               $ mkToggle (NBFULL ?? NOBORDERS ?? EOT) myDefaultLayout
  where
    myDefaultLayout = withBorder myBorderWidth tall
                                           ||| noBorders monocle
                                           ||| floats
                                           ||| noBorders tabs
                                           ||| grid


myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 ", " 6 ", " 7 ", " 8 ", " 9 "]
--myWorkspaces = [" 1 ", " 2 ", " 3 ", " 4 ", " 5 "]
-- myWorkspaces = [" dev ", " www ", " sys ", " doc ", " vbox ", " chat ", " mus ", " vid ", " gfx "]
-- myWorkspaces =
--         " 1 : <fn=2>\xf111</fn> " :
--         " 2 : <fn=2>\xf1db</fn> " :
--         " 3 : <fn=2>\xf192</fn> " :
--         " 4 : <fn=2>\xf025</fn> " :
--         " 5 : <fn=2>\xf03d</fn> " :
--         " 6 : <fn=2>\xf1e3</fn> " :
--         " 7 : <fn=2>\xf07b</fn> " :
--         " 8 : <fn=2>\xf21b</fn> " :
--         " 9 : <fn=2>\xf21e</fn> " :
--         []

myWorkspaceIndices = M.fromList $ zipWith (,) myWorkspaces [1..]

clickable ws = "<action=xdotool key super+"++show i++">"++ws++"</action>"
    where i = fromJust $ M.lookup ws myWorkspaceIndices

myManageHook :: XMonad.Query (Data.Monoid.Endo WindowSet)
myManageHook = composeAll
  -- 'doFloat' forces a window to float.  Useful for dialog boxes and such.
  -- using 'doShift ( myWorkspaces !! 7)' sends program to workspace 8!
  -- I'm doing it this way because otherwise I would have to write out the full
  -- name of my workspaces and the names would be very long if using clickable workspaces.
  [ className =? "confirm"            --> doFloat
  , className =? "file_progress"      --> doFloat
  , className =? "flameshot"          --> doFloat
  , className =? "dialog"             --> doFloat
  , className =? "download"           --> doFloat
  , className =? "error"              --> doFloat
  , className =? "Gimp"               --> doFloat
  , className =? "notification"       --> doFloat
  , className =? "pinentry-gtk-2"     --> doFloat
  , className =? "VirtualBox Machine" --> doFloat
  , className =? "splash"             --> doFloat
  , className =? "toolbar"            --> doFloat
  , className =? "Yad"                --> doCenterFloat
  , className =? "cs2"                --> doCenterFloat
  , title =? "Oracle VM VirtualBox Manager"   --> doFloat
  , title =? "Order Chain - Market Snapshots" --> doFloat
  , title =? "emacs-run-launcher" --> doFloat
  --, title =? "Mozilla Firefox"     --> doShift ( myWorkspaces !! 1 )
  , className =? "brave"   --> doShift ( myWorkspaces !! 1 )
  , className =? "mpv"             --> doShift ( myWorkspaces !! 7 )
  , className =? "Gimp"            --> doShift ( myWorkspaces !! 8 )
  , className =? "vmware" --> doShift  ( myWorkspaces !! 4 )
  , (className =? "firefox" <&&> resource =? "Dialog") --> doFloat  -- Float Firefox Dialog
  , isFullscreen -->  doFullFloat
  ] <+> namedScratchpadManageHook myScratchPads

soundDir = "/opt/sounds/" -- The directory that has the sound files

startupSound  = soundDir ++ "startup-01.mp3"
shutdownSound = soundDir ++ "shutdown-02.mp3"
dmenuSound    = soundDir ++ "menu-01.mp3"

subtitle' ::  String -> ((KeyMask, KeySym), NamedAction)
subtitle' x = ((0,0), NamedAction $ map toUpper
                      $ sep ++ "\n-- " ++ x ++ " --\n" ++ sep)
  where
    sep = replicate (6 + length x) '-'


showKeybindings :: [((KeyMask, KeySym), NamedAction)] -> NamedAction
showKeybindings x = addName "Show Keybindings" $ io $ do
  h <- spawnPipe $ "yad --text-info --fontname=\"SauceCodePro Nerd Font Mono 12\" --fore=#46d9ff back=#282c36 --center --geometry=1200x800 --title \"XMonad keybindings\""
  --hPutStr h (unlines $ showKm x) -- showKM adds ">>" before subtitles
  hPutStr h (unlines $ showKmSimple x) -- showKmSimple doesn't add ">>" to subtitles
  hClose h
  return ()

myKeys :: XConfig l0 -> [((KeyMask, KeySym), NamedAction)]
myKeys c =
  --(subtitle "Custom Keys":) $ mkNamedKeymap c $
  let subKeys str ks = subtitle' str : mkNamedKeymap c ks in
  subKeys "Xmonad Essentials"
  [ ("M-C-r", addName "Recompile XMonad"       $ spawn "ghc --make $HOME/.config/xmonad/xmonad.hs -i -ilib -dynamic -fforce-recomp  -o $HOME/.config/xmonad/xmonad-x86_64-linux ; xmonad --restart")
  , ("M-S-r", addName "Restart XMonad"         $ spawn "xmonad --restart")
  --, ("M-S-q", addName "Quit XMonad"            $ sequence_ [spawn (mySoundPlayer ++ shutdownSound), io exitSuccess])
  --, ("M-S-q", addName "Quit XMonad"            $ io exitSuccess)
  , ("M-S-c", addName "Kill focused window"    $ kill1)
  , ("M-S-q", addName "Quit XMonad"            $ spawn "dm-logout")
  , ("M-S-a", addName "Kill all windows on WS" $ killAll)
  , ("M-S-<Return>", addName "Run prompt"      $ sequence_ [spawn (mySoundPlayer ++ dmenuSound), spawn "PATH='$PATH' dmenu_path | dmenu_run -c -bw 2 -l 20 -g 4"])
  , ("M-S-b", addName "Toggle bar show/hide"   $ sendMessage ToggleStruts)
  , ("M-/", addName "DTOS Help"                $ spawn "dtos-help")]

  ^++^ subKeys "Switch to workspace"
  [ ("M-1", addName "Switch to workspace 1"    $ (windows $ W.greedyView $ myWorkspaces !! 0))
  , ("M-2", addName "Switch to workspace 2"    $ (windows $ W.greedyView $ myWorkspaces !! 1))
  , ("M-3", addName "Switch to workspace 3"    $ (windows $ W.greedyView $ myWorkspaces !! 2))
  , ("M-4", addName "Switch to workspace 4"    $ (windows $ W.greedyView $ myWorkspaces !! 3))
  , ("M-5", addName "Switch to workspace 5"    $ (windows $ W.greedyView $ myWorkspaces !! 4))
  , ("M-6", addName "Switch to workspace 6"    $ (windows $ W.greedyView $ myWorkspaces !! 5))
  , ("M-7", addName "Switch to workspace 7"    $ (windows $ W.greedyView $ myWorkspaces !! 6))
  , ("M-8", addName "Switch to workspace 8"    $ (windows $ W.greedyView $ myWorkspaces !! 7))
  , ("M-9", addName "Switch to workspace 9"    $ (windows $ W.greedyView $ myWorkspaces !! 8))]

  ^++^ subKeys "Send window to workspace"
  [ ("M-S-1", addName "Send to workspace 1"    $ (windows $ W.shift $ myWorkspaces !! 0))
  , ("M-S-2", addName "Send to workspace 2"    $ (windows $ W.shift $ myWorkspaces !! 1))
  , ("M-S-3", addName "Send to workspace 3"    $ (windows $ W.shift $ myWorkspaces !! 2))
  , ("M-S-4", addName "Send to workspace 4"    $ (windows $ W.shift $ myWorkspaces !! 3))
  , ("M-S-5", addName "Send to workspace 5"    $ (windows $ W.shift $ myWorkspaces !! 4))
  , ("M-S-6", addName "Send to workspace 6"    $ (windows $ W.shift $ myWorkspaces !! 5))
  , ("M-S-7", addName "Send to workspace 7"    $ (windows $ W.shift $ myWorkspaces !! 6))
  , ("M-S-8", addName "Send to workspace 8"    $ (windows $ W.shift $ myWorkspaces !! 7))
  , ("M-S-9", addName "Send to workspace 9"    $ (windows $ W.shift $ myWorkspaces !! 8))]

  ^++^ subKeys "Move window to WS and go there"
  [ ("M-S-<Page_Down>", addName "Move window to next WS"   $ shiftTo Next nonNSP >> moveTo Next nonNSP)
  , ("M-S-<Page_Up>", addName "Move window to prev WS" $ shiftTo Prev nonNSP >> moveTo Prev nonNSP)]

  ^++^ subKeys "Window navigation"
  [ ("M-j", addName "Move focus to next window"                $ windows W.focusDown)
  , ("M-k", addName "Move focus to prev window"                $ windows W.focusUp)
  , ("M-m", addName "Move focus to master window"              $ windows W.focusMaster)
  , ("M-S-j", addName "Swap focused window with next window"   $ windows W.swapDown)
  , ("M-S-k", addName "Swap focused window with prev window"   $ windows W.swapUp)
  , ("M-S-m", addName "Swap focused window with master window" $ windows W.swapMaster)
  , ("M-<Backspace>", addName "Move focused window to master"  $ promote)
  , ("M-S-,", addName "Rotate all windows except master"       $ rotSlavesDown)
  , ("M-S-.", addName "Rotate all windows current stack"       $ rotAllDown)]

  -- Dmenu scripts (dmscripts)
  -- In Xmonad and many tiling window managers, M-p is the default keybinding to
  -- launch dmenu_run, so I've decided to use M-p plus KEY for these dmenu scripts.
  ^++^ subKeys "Dmenu scripts"
  [ ("M-p h", addName "List all dmscripts"     $ spawn "dm-hub")
  , ("M-p a", addName "Choose ambient sound"   $ spawn "dm-sounds")
  , ("M-p b", addName "Set background"         $ spawn "dm-setbg")
  , ("M-p c", addName "Choose color scheme"    $ spawn "~/.local/bin/dtos-colorscheme")
  , ("M-p C", addName "Pick color from scheme" $ spawn "dm-colpick")
  , ("M-p e", addName "Edit config files"      $ spawn "dm-confedit")
  , ("M-p i", addName "Take a screenshot"      $ spawn "dm-maim")
  , ("M-p k", addName "Kill processes"         $ spawn "dm-kill")
  , ("M-p m", addName "View manpages"          $ spawn "dm-man")
  , ("M-p n", addName "Store and copy notes"   $ spawn "dm-note")
  , ("M-p o", addName "Browser bookmarks"      $ spawn "dm-bookman")
  , ("M-p p", addName "Passmenu"               $ spawn "passmenu -p \"Pass: \"")
  , ("M-p q", addName "Logout Menu"            $ spawn "dm-logout")
  , ("M-p r", addName "Listen to online radio" $ spawn "dm-radio")
  , ("M-p s", addName "Search various engines" $ spawn "dm-websearch")
  , ("M-p t", addName "Translate text"         $ spawn "dm-translate")]

  ^++^ subKeys "Favorite programs"
  [ ("M-<Return>", addName "Launch terminal"   $ spawn (myTerminal))
  , ("M-b", addName "Launch web browser"       $ spawn (myBrowser))
  , ("M-d", addName "Launch Doom Emacs"        $ spawn "emacsclient -c -a '' --eval '(progn (+doom-dashboard/open (selected-frame)))'")
  , ("M-M1-h", addName "Launch htop"           $ spawn (myTerminal ++ " -e htop"))
  , ("M-<F2>", addName "Selection screenshot" $ spawn "QT_STYLE_OVERRIDE=qt5ct flameshot gui")
  , ("M-C-v", addName "Primary paste"          $ spawn "xdotool click 1")
  , ("M-v", addName "Selection paste"          $ spawn "$HOME/.local/bin/paste_primary")
  , ("C-M1-t", addName "Secondary Terminal"    $ spawn "xterm")
  , ("M-S-l", addName "Input lock"             $ spawn "xtrlock")
  , ("M-f", addName "Freetube"                 $ spawn "freetube")
  , ("M-n", addName "Thunar"                   $ spawn "thunar")]

  ^++^ subKeys "Monitors"
  [ ("M-.", addName "Switch focus to next monitor" $ nextScreen)
  , ("M-,", addName "Switch focus to prev monitor" $ prevScreen)
  , ("M-S-<Tab>", addName "Switch focus to next monitor" $ nextScreen)]

  -- Switch layouts
  ^++^ subKeys "Switch layouts"
  [ ("M-<Escape>", addName "Switch to next layout"   $ sendMessage NextLayout)
--  , ("M-<Space>", addName "Toggle noborders/full" $ sendMessage (MT.Toggle NBFULL) >> sendMessage ToggleStruts)]
  , ("M-<Space>", addName "Toggle noborders/full" $ sendMessage (MT.Toggle NBFULL))]
  -- Window resizing
  ^++^ subKeys "Window resizing"
  [ ("M-l", addName "Shrink master window"        $ sendMessage Shrink)
  , ("M-h", addName "Expand master window"        $ sendMessage Expand)
  , ("M-M1-j", addName "Shrink window vertically" $ sendMessage MirrorShrink)
  , ("M-M1-k", addName "Expand window vertically" $ sendMessage MirrorExpand)]

  -- Floating windows
  ^++^ subKeys "Floating windows"
  [ ("M-t", addName "Sink a floating window"     $ withFocused $ windows . W.sink)
--("M-f", addName "Toggle float layout"        $ sendMessage (T.Toggle "floats"))
  , ("M-S-t", addName "Sink all floated windows" $ sinkAll)]

  -- Increase/decrease spacing (gaps)
  ^++^ subKeys "Window spacing (gaps)"
  [ ("C-M-j", addName "Decrease window spacing" $ decWindowSpacing 4)
  , ("C-M-k", addName "Increase window spacing" $ incWindowSpacing 4)
  , ("C-M-h", addName "Decrease screen spacing" $ decScreenSpacing 4)
  , ("C-M-l", addName "Increase screen spacing" $ incScreenSpacing 4)]

  -- Increase/decrease windows in the master pane or the stack
  ^++^ subKeys "Increase/decrease windows in master pane or the stack"
  [ ("M-S-<Up>", addName "Increase clients in master pane"   $ sendMessage (IncMasterN 1))
  , ("M-S-<Down>", addName "Decrease clients in master pane" $ sendMessage (IncMasterN (-1)))
  , ("M-=", addName "Increase max # of windows for layout"   $ increaseLimit)
  , ("M--", addName "Decrease max # of windows for layout"   $ decreaseLimit)]

  -- Sublayouts
  ^++^ subKeys "Some other description"-- This is used to push windows to  ^++^ subKeys "Mocp music player"
  [ ("M-u p", addName "mocp play"                $ spawn "mocp --play")
  , ("M-u l", addName "mocp next"                $ spawn "mocp --next")
  , ("M-u h", addName "mocp prev"                $ spawn "mocp --previous")
  , ("M-u <Space>", addName "mocp toggle pause"  $ spawn "mocp --toggle-pause")]

  ^++^ subKeys "GridSelect"
  -- , ("C-g g", addName "Select favorite apps"     $ runSelectedAction' defaultGSConfig gsCategories)
  [ ("C-M-<Return>", addName "Select favorite apps" $ spawnSelected'
       $ gsGames ++ gsEducation ++ gsInternet ++ gsMultimedia ++ gsOffice ++ gsSettings ++ gsSystem ++ gsUtilities)
  , ("C-M-c", addName "Select favorite apps"    $ spawnSelected' gsCategories)
  , ("C-M-t", addName "Goto selected window"    $ goToSelected $ mygridConfig myColorizer)
  , ("C-M-b", addName "Bring selected window"   $ bringSelected $ mygridConfig myColorizer)
  , ("C-M-1", addName "Menu of games"           $ spawnSelected' gsGames)
  , ("C-M-2", addName "Menu of education apps"  $ spawnSelected' gsEducation)
  , ("C-M-3", addName "Menu of Internet apps"   $ spawnSelected' gsInternet)
  , ("C-M-4", addName "Menu of multimedia apps" $ spawnSelected' gsMultimedia)
  , ("C-M-5", addName "Menu of office apps"     $ spawnSelected' gsOffice)
  , ("C-M-6", addName "Menu of settings apps"   $ spawnSelected' gsSettings)
  , ("C-M-7", addName "Menu of system apps"     $ spawnSelected' gsSystem)
  , ("C-M-8", addName "Menu of utilities apps"  $ spawnSelected' gsUtilities)]

  -- Multimedia Keys
  ^++^ subKeys "Multimedia keys"
  [ ("<XF86AudioPlay>", addName "mocp play"           $ spawn "mocp --play")
  , ("<XF86AudioPrev>", addName "mocp next"           $ spawn "mocp --previous")
  , ("<XF86AudioNext>", addName "mocp prev"           $ spawn "mocp --next")
  , ("<XF86AudioMute>", addName "Toggle audio mute"   $ spawn "amixer set Master toggle")
  , ("<XF86AudioLowerVolume>", addName "Lower vol" $ spawn "pactl set-sink-volume @DEFAULT_SINK@ -5%")
  , ("<XF86AudioRaiseVolume>", addName "Raise vol" $ spawn "pactl set-sink-volume @DEFAULT_SINK@ +5%")
  , ("<XF86MonBrightnessDown>", addName "Decrease brightness" $ spawn "$HOME/.local/bin/brightness-decrease")
  , ("<XF86MonBrightnessUp>", addName "Increase brightness" $ spawn "$HOME/.local/bin/brightness-increase")
  , ("<XF86HomePage>", addName "Open home page"       $ spawn (myBrowser ++ " https://www.youtube.com/c/DistroTube"))
  , ("<XF86Search>", addName "Web search (dmscripts)" $ spawn "dm-websearch")
  , ("<XF86Mail>", addName "Email client"             $ runOrRaise "thunderbird" (resource =? "thunderbird"))
  , ("<XF86Calculator>", addName "Calculator"         $ runOrRaise "qalculate-gtk" (resource =? "qalculate-gtk"))
  , ("<XF86Eject>", addName "Eject /dev/cdrom"        $ spawn "eject /dev/cdrom")
  , ("<Print>", addName "Take screenshot (dmscripts)" $ spawn "dm-maim")
  , ("<F8>", addName "Toggle audio output" $ spawn "pactl set-sink-port alsa_output.pci-0000_00_1f.3.analog-stereo $(pactl list sinks | grep -A 15 'analog-stereo' | grep 'Active Port' | grep -q 'speaker' && echo 'analog-output-headphones' || echo 'analog-output-speaker'); pactl set-sink-mute alsa_output.pci-0000_00_1f.3.analog-stereo 0; pactl set-sink-volume alsa_output.pci-0000_00_1f.3.analog-stereo 20%")
  ]
  -- The following lines are needed for named scratchpads.
    where nonNSP          = WSIs (return (\ws -> W.tag ws /= "NSP"))
          nonEmptyNonNSP  = WSIs (return (\ws -> isJust (W.stack ws) && W.tag ws /= "NSP"))

main :: IO ()
main = do

 -- Launching three instances of xmobar on their monitors.
  xmproc0 <- spawnPipe ("xmobar -x 0 $HOME/.config/xmobar/.xmobarrc")
  xmproc1 <- spawnPipe ("xmobar -x 1 $HOME/.config/xmobar/.xmobarrc-secondary")
--  xmproc2 <- spawnPipe ("xmobar -x 2 $HOME/.config/xmobar/" ++ colorScheme ++ "-xmobarrc")
  -- the xmonad, ya know...what the WM is named after!
  xmonad $ addDescrKeys' ((mod4Mask, xK_F1), showKeybindings) myKeys $ ewmh $ docks $ def
    { manageHook         = myManageHook <+> manageDocks
    , handleEventHook    = windowedFullscreenFixEventHook <> swallowEventHook (className =? "Alacritty"  <||> className =? "st-256color" <||> className =? "XTerm") (return True) <> trayerPaddingXmobarEventHook
    , modMask            = myModMask
    , terminal           = myTerminal
    , startupHook        = myStartupHook
    , layoutHook         = showWName' myShowWNameTheme $ myLayoutHook
    , workspaces         = myWorkspaces
    , borderWidth        = myBorderWidth
    , normalBorderColor  = myNormColor
    , focusedBorderColor = myFocusColor
    , logHook = dynamicLogWithPP $  filterOutWsPP [scratchpadWorkspaceTag] $ xmobarPP
        { ppOutput = \x -> hPutStrLn xmproc0 x   -- xmobar on monitor 1
                        >> hPutStrLn xmproc1 x   -- xmobar on monitor 2
          , ppCurrent = xmobarColor color06 "" . wrap
              ("<box type=Top width=2 mt=2 color=" ++ color06 ++ ">" ++ 
               "<box type=Bottom width=2 mb=2 color=" ++ color06 ++ ">") 
               "</box></box>"
             -- Visible but not current workspace
          , ppVisible = xmobarColor color06 "" . wrap
              ("<box type=Bottom width=2 mb=2 color=" ++ color06 ++ ">") 
               "</box>" . clickable          
             -- Hidden workspace
       , ppHidden = xmobarColor color05 "" . wrap
                     ("<box type=Top width=2 mt=2 color=" ++ color05 ++ ">") "</box>" . clickable
          -- Hidden workspaces (no windows)
        , ppHiddenNoWindows = xmobarColor color05 ""  . clickable
          -- Title of active window
        , ppTitle = xmobarColor color16 "" . shorten 60
          -- Separator character
        , ppSep =  "<fc=" ++ color09 ++ "> <fn=1>|</fn> </fc>"
          -- Urgent workspace
        , ppUrgent = xmobarColor color02 "" . wrap "!" "!"
          -- Adding # of windows on current workspace to the bar
        , ppExtras  = [windowCount]
          -- order of things in xmobar
        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
        }
    }
