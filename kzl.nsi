;2013/6/19
;--------------------------------
;Include Modern UI
!include "MUI2.nsh"
;--------------------------------
; user defined constants
!define PRODUCT_NAME "Virtual Geology"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "PKUGIS"
!define PRODUCT_WEBSITE "http://3d.pku.edu.cn/3d/welcome"
!define PAGE_ID Application
; registry key value
!define PRODUCT_ROOT_KEY HKCU
!define PRODUCT_SUB_KEY "Software\${PRODUCT_NAME} ${PRODUCT_VERSION}"
!define PRODUCT_UN_ROOT_KEY HKLM
!define PRODUCT_UN_SUB_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME} ${PRODUCT_VERSION}"
; constants related with current folder
!define PRODUCT_EXE "Virtual Geology.exe"
!define PRODUCT_LICENSE ".\licenses.txt"
;--------------------------------
;Interface Settings
;These settings apply to all pages.

; show warning message box if cancel
!define MUI_ABORTWARNING
;!define MUI_ICON "${NSISDIR}\Contrib\Graphics\Icons\modern-install.ico"
;!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\modern-uninstall.ico"
;--------------------------------
;General
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "${PRODUCT_NAME} ${PRODUCT_VERSION} Installer.exe"
; 3 ways to modify $INSTDIR : InstallDir InstallDirRegKey  MUI_PAGE_DIRECTORY
InstallDir "$PROGRAMFILES\${PRODUCT_NAME}"
;This attribute tells the installer to check a string in the registry, and use it for the install dir if that string is valid. If this attribute is present, it will override the InstallDir attribute if the registry key is valid, otherwise it will fall back to the InstallDir default.
;Get installation folder from registry if available
;HKLM is for all users, HKCU is for the current user.
;InstallDirRegKey HKCU "Software\Modern UI Test" ""
InstallDirRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}" ""

;ShowInstDetails show  ; hide show
;ShowUnInstDetails show

;Request application privileges for Windows Vista
;none|user|highest|admin
;must be admin to create folder and copy files!!!
RequestExecutionLevel admin

;--------------------------------
;Variables
Var StartMenuFolder
;--------------------------------
;Pages

;installer pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${PRODUCT_LICENSE}"
!insertmacro MUI_PAGE_COMPONENTS
; store the install dir into $INSTDIR
!insertmacro MUI_PAGE_DIRECTORY
;Store the folder in $StartMenuFolder
!insertmacro MUI_PAGE_STARTMENU ${PAGE_ID} $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
;!insertmacro MUI_PAGE_FINISH

;uninstaller pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
;!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages
!define MUI_LANGDLL_ALLLANGUAGES
!insertmacro MUI_LANGUAGE "English"
;!insertmacro MUI_LANGUAGE "SimpChinese"
;!insertmacro MUI_LANGUAGE "TradChinese"

;--------------------------------
;Installer Sections

Function .onInit
;!insertmacro MUI_LANGDLL_DISPLAY
; dialog to choose language
FunctionEnd

Section "Main Section" MainSection

; install dir
; Sets the output path ($OUTDIR) and creates it (recursively if necessary)
SetOutPath $INSTDIR
;on|off|try|ifnewer|ifdiff|lastused
SetOverwrite ifnewer

; copy all files to install dir
FILE /r /x *.nsi /x SecondLife *

; copy second life settings to appdata folder
SetOutPath $APPDATA
FILE /r SecondLife

; exe path
!define PRODUCT_EXE_PATH "$INSTDIR\${PRODUCT_EXE}"
!define PRODUCT_UN_EXE_PATH "$INSTDIR\Uninstall.exe"

;Create uninstaller
WriteUninstaller "${PRODUCT_UN_EXE_PATH}"

; start menu dir
!define START_MENU_DIR "$SMPROGRAMS\$StartMenuFolder"
!insertmacro MUI_STARTMENU_WRITE_BEGIN ${PAGE_ID}
CreateDirectory "${START_MENU_DIR}"
CreateShortCut "${START_MENU_DIR}\${PRODUCT_NAME}.lnk" "${PRODUCT_EXE_PATH}"
CreateShortCut "${START_MENU_DIR}\Uninstall.lnk" "${PRODUCT_UN_EXE_PATH}"
!insertmacro MUI_STARTMENU_WRITE_END

; desktop
CreateShortCut "$DESKTOP\${PRODUCT_NAME}.lnk" "${PRODUCT_EXE_PATH}"

; registry
;WriteRegStr root_key subkey key_name value
;Store installation folder
WriteRegStr ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}" ""  "$INSTDIR"

;Write uninstaller to control panel
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "DisplayIcon" "${PRODUCT_EXE_PATH}"
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "DisplayName" "${PRODUCT_NAME}"
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "UninstallString" "$INSTDIR\Uninstall.exe"
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "URLInfoAbout" "${PRODUCT_WEBSITE}"
WriteRegStr ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}" "HelpLine" "${PRODUCT_WEBSITE}"

Call Bind2Client
SectionEnd

;Section "Test"
;SectionEnd

FUNCTION Bind2Client
;Bind secondlife protocol to client
WriteRegStr HKEY_CLASSES_ROOT "secondlife" "(default)" "URL:Second Life"
WriteRegStr HKEY_CLASSES_ROOT "secondlife" "URL Protocol" ""
WriteRegStr HKEY_CLASSES_ROOT "secondlife\DefaultIcon" "" '"$INSTDIR\Virtual Art Country.exe"'
WriteRegExpandStr HKEY_CLASSES_ROOT "secondlife\shell\open\command" "" '"$INSTDIR\${PRODUCT_EXE}" -url "%1"'
FunctionEnd
;--------------------------------
;Uninstaller Section

; system callback
Function un.onInit
;!insertmacro MUI_UNGETLANGUAGE
MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Are you sure you want to completely remove $(^Name) and all of its components?" IDYES +2
Abort
FunctionEnd

; system callback
Function un.onUninstSuccess
HideWindow
MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Section "Uninstall"
RMDir /r $INSTDIR

!insertmacro MUI_STARTMENU_GETFOLDER ${PAGE_ID} $StartMenuFolder
!define START_MENU_DIR2 "$SMPROGRAMS\$StartMenuFolder"
; Delete "${START_MENU_DIR2}\${PRODUCT_NAME}.lnk"
; Delete "${START_MENU_DIR2}\Uninstall.lnk"
RMDir /r "${START_MENU_DIR2}"

Delete "$DESKTOP\${PRODUCT_NAME}.lnk"

;DeleteRegKey /ifempty ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}"
DeleteRegKey ${PRODUCT_ROOT_KEY} "${PRODUCT_SUB_KEY}"
DeleteRegKey ${PRODUCT_UN_ROOT_KEY} "${PRODUCT_UN_SUB_KEY}"

SectionEnd

