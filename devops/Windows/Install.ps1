
# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
}

#####################
#### PERMISSIONS ####
#####################

# SET THE COMPUTER EXECUTION POLICY
Set-ExecutionPolicy RemoteSigned -Force

###################
#### VARIABLES ####
###################

$PROGRAM_DIR = "C:\Program Files(x84)"
$RCS_PROGRAMS_DIR = "$PROGRAMS_DIR\Recursion"
$RCS_COOKIE_CUTTER_DIR = "$RCS_PROGRAMS_DIR\CookieCutter"

$STARTUP_DIR = "C:\Users\$Env:USERNAME\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$STARTUP_FILE = "$STARTUP_DIR\StartCookieCutter.bat"

$rcsProgramsDirExists = Test-Path $RCS_PROGRAMS_DIR
$cookieCutterDirExists = Test-Path $RCS_COOKIE_CUTTER_DIR


##############
#### MAIN ####
##############

##INSTALL CHOCOLATEY
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))



##INSTALL DEPENDENCIES WITH CHOCOLATEY

#Check for Git
$hasGit = git
if($hasGit -contains 'is not a recognized cmdlet'){
    echo 'Installing Git'
    choco install -y git
}

#Check for nodejs
$hadNode = node
if($hasNode -contains 'is not a recognized cmdlet'){
    echo 'Installing NodeJS'
    choco install -y nodejs
}

#Check for FFMPEG
$hasFfmpeg = ffmpeg
if($hasFfmpef -contains 'is not a recognized cmdlet'){
    echo 'Installing FFMPEG'
    choco install -y ffmpeg
}



## SET UP FILE SYSTEM

if(! $rcsProgramsDirExists ){
    New-Item -ItemType directory -Path $RCS_PROGRAMS_DIR
}

if(! $cookieCutterDirExists ){
    New-Item -ItemType directory -Path $RCS_COOKIE_CUTTER_DIR
}



## DOWNLOAD THE REPOSITORY FROM GIT
git clone https://github.com/BrandonCookeDev/RCSCookieCutter.git $RCS_COOKIE_CUTTER_DIR



## SETUP AND RUN SERVER

cd $COOKIE_CUTTER_DIR
npm run-script installAll
node server



## PUT SERVER STARTUP SCRIPT IN STARTUP FOLDER

cd $STARTUP_DIR
New-Item -ItemType File -Name $STARTUP_FILE
echo @ECHO OFF > $STARTUP_FILE
echo "cd $RCS_COOKIE_CUTTER_DIR" >> $STARTUP_FILE
echo "git pull origin master" >> $STARTUP_FILE
echo "npm run-script installAll" >> $STARTUP_FILE
echo "node server" >> $STARTUP_FILE

