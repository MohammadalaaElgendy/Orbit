; Script generated for Orbit App
#define MyAppName "Orbit"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Mohammad Alaa"
#define MyAppExeName "orbit.exe"
#define MyAppAssocName "Orbit Protocol"
#define MyAppAssocKey "OrbitProtocol"
#define MyAppScheme "io.supabase.orbit"

[Setup]
AppId={{D3F7A1B2-C4D5-4E6F-8A9B-0C1D2E3F4G5H}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
UninstallDisplayIcon={app}\{#MyAppExeName}
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
ChangesAssociations=yes
DisableProgramGroupPage=yes
PrivilegesRequired=admin
OutputDir=C:\Users\mo7am\OneDrive\سطح المكتب
OutputBaseFilename=OrbitSetup
SetupIconFile="F:\Programming\Flutter\Orbit\windows\runner\resources\app_icon.ico"
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "F:\Programming\Flutter\Orbit\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "F:\Programming\Flutter\Orbit\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Registry]
; تسجيل البروتوكول في الـ Registry لجميع المستخدمين
Root: HKA; Subkey: "Software\Classes\{#MyAppScheme}"; ValueType: string; ValueName: ""; ValueData: "URL:Orbit Protocol"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppScheme}"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\{#MyAppScheme}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletekey

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
