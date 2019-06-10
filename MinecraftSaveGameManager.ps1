##############################
#region USING:

Add-Type -assembly System.Windows.Forms

#endregion USING
#
##############################

##############################
#region Language Localization

$ProgramName = "Minecraft Save Game Manager"

#MainLayout
$BackupLabel = "Backup Minecraft Game"
$RestoreLabel = "Restore Minecraft Game"

#BackupLayout
$BackupInstructions = "Select a Minecraft Game to Backup"
$BackButtonText = "Return"
$BackupButtonWhenGameSelected = "Backup"
$BackupButtonWhenNoGameSelected = $BackupInstructions + "!"

#RestoreLayout
$RestoreInstructions = "Select a Minecraft Game to Restore"
$RestoreName = "Restore Save Game"
$RestoreButtonWhenGameSelected = "Restore"
$RestoreButtonWhenNoGameSelected = $RestoreInstructions + "!"

#$BeginBackup
$WasBackedUp = "Was backed up to:"
$WasNotBackedUp = " Was not backed up to:"
$BackupFailed = "Backup Failed!"
$Because = "Because:"
$Success = "Success!"
$ContactSupport = "Please Contact Support."

#$BeginRestore
$Warning = "WARNING!"
$BackedUpGame = "Backed up game:"
$WillOverWrite = "Will OVERWRITE the current game:"
$ActionCannotBeUndone = "THIS ACTION CANNOT BE UNDONE!"
$AreYouSure = "Are you sure you want to do this?"
$DeleteFailed = "Delete Failed!"
$CouldNotBeRemoved = "Could not be removed because:"
$WasRestoredFrom = "Was Restored from:"
$CopyFailed = "Copy Failed!"
$CouldNotBeCopied = "Could not be copied to"

#endregion Language Localization
#
##############################

##############################
#region Variables:

#Where Minecraft save games are:
$SaveRoot = $env:APPDATA + "\.minecraft\saves\"

#Name of Minecraft Save Game Manager Backup Folder:
$BackupFolderName = ".MCSGMBackupFolder"

#Where Minecraft backup game saves are (used by this script):
$BackupRoot = $SaveRoot + $BackupFolderName +"\"

#Global Variables:
$Global:MainForm = $null
$Global:ControlLayout = $null
$Global:GameList = $null
$Global:SelectedGame = $null
$Global:Operation = $null

#Form Dimensions:
$FormWidth = 600
$FormHeight = 500

#endregion Variables
#
##############################

##############################
#region Functions


    ##############################
    #region Form

#A Function to build the MainForm
function BuildMainForm
{

    #Create A Form:
    $Global:MainForm = New-Object System.Windows.Forms.Form
    $Global:MainForm.FormBorderStyle = "Fixed3D"
    $Global:MainForm.MaximizeBox = $false
    $Global:MainForm.Width = $FormWidth
    $Global:MainForm.Height = $FormHeight
      
}

#A Function to remove all MainForm controls and repopulate it with a list of $Global:ControlLayout
Function RepopulateMainFormControls
{
    
    #Clear all controls currently in the form:
    $Global:MainForm.Controls.Clear()

    #Add new controls to form:
    foreach($Control in ($Global:ControlLayout))
    {
        $Global:MainForm.Controls.Add($Control)
    }
}

    #endregion Form
    #
    ##############################

    ##############################
    #region Form Control Layouts

#A Function to Create the Main Layout Controls and populate them into $Global:ControlLayout:
function CreateMainLayout
{
    $ButtonWidth = 500
    $ButtonHeight = 125
    #Create Backup Button:
    $MLBackupBtn = New-Object System.Windows.Forms.Button
    $MLBackupBtn.Location = New-Object System.Drawing.Size((($FormWidth/2)-($ButtonWidth/2)),(($FormHeight/2)-($ButtonHeight + 50)))
    $MLBackupBtn.Size = New-Object System.Drawing.Size($ButtonWidth,$ButtonHeight)
    $MLBackupBtn.Text = $BackupLabel
    #Click Event
    $MLBackupBtn.Add_Click($BackupOperation)
    
    
    #Create Restore Button
    $MLRestoreBtn = New-Object System.Windows.Forms.Button
    $MLRestoreBtn.Location = New-Object System.Drawing.Size((($FormWidth/2)-($ButtonWidth/2)),(($FormHeight/2)+50))
    $MLRestoreBtn.Size = New-Object System.Drawing.Size($ButtonWidth,$ButtonHeight)
    $MLRestoreBtn.Text = $RestoreLabel
    $MLRestoreBtn.Add_Click($RestoreOperation)

    #Add all elements to the $Global:ControlLayout:
    $Global:ControlLayout = $MLBackupBtn, $MLRestoreBtn
    
}


#A Function to build the Backup Layout Controls and populate them into $Global:ControlLayout:
function CreateBackupLayout
{

    #Create Back Button:
    $BLBackButton = New-Object System.Windows.Forms.Button
    $BLBackButton.Location = New-Object System.Drawing.Size(0,0)
    $BLBackButton.Size = New-Object System.Drawing.Size(200,25)
    $BLBackButton.Text = "< " + $BackButtonText
    #Click Event
    $BLBackButton.Add_Click($ReturnToMain)


    #Create a Info Label
    $BLBackupLabel = New-Object System.Windows.Forms.Label
    $BLBackupLabel.Location = New-Object System.Drawing.Size(50,75)
    $BLBackupLabel.Font
    $BLBackupLabel.Size = New-Object System.Drawing.Size(485,50)
    $BLBackupLabel.Text = $BackupInstructions + ":" 


    #Create a select list
    $BLBackupList = New-Object System.Windows.Forms.ListBox
    $BLBackupList.Name = "BackupList"
    $BLBackupList.Location = New-Object System.Drawing.Size(50,100)
    $BLBackupList.Size = New-Object System.Drawing.Size(485,300)
    $BLBackupList.SelectionMode = 'One'
    #Get items to add to the list:
    $GameListing = GetGameListing
    foreach ($Game in $GameListing)
    {
        $BLBackupList.Items.Add($Game.Name)
    }
    $BLBackupList.Add_Click($SelectedBackupGame)

    #Crate Backup Button
    $BLBackupButton = New-Object System.Windows.Forms.Button
    $BLBackupButton.Location = New-Object System.Drawing.Size(50, 390)
    $BLBackupButton.Size = New-Object System.Drawing.Size(485,50)
    $BLBackupButton.Text = $BackupButtonWhenNoGameSelected
    $BLBackupButton.Name = "BackupButton"
    $BLBackupButton.Enabled = $false
    #Click Event
    $BLBackupButton.Add_Click($BeginBackup)


    #Add all elements to the Global:ControlLayout:
    $Global:ControlLayout = $BLBackupButton, $BLBackButton, $BLBackupList, $BLBackupLabel
    
}

#A Function to build the Restore Layout Controls and populate them into $Global:ControlLayout:
function CreateRestoreLayout
{

    #Create Back Button:
    $RLBackButton = New-Object System.Windows.Forms.Button
    $RLBackButton.Location = New-Object System.Drawing.Size(0,0)
    $RLBackButton.Size = New-Object System.Drawing.Size(200,25)
    $RLBackButton.Text = "< " + $BackButtonText
    #Click Event
    $RLBackButton.Add_Click($ReturnToMain)


    #Create a Info Label
    $RLRestoreLabel = New-Object System.Windows.Forms.Label
    $RLRestoreLabel.Location = New-Object System.Drawing.Size(50,75)
    $RLRestoreLabel.Size = New-Object System.Drawing.Size(485,50)
    $RLRestoreLabel.Text = $RestoreInstructions + ":" 


    #Create a select list
    $RLRestoreList = New-Object System.Windows.Forms.ListBox
    $RLRestoreList.Name = "RestoreList"
    $RLRestoreList.Location = New-Object System.Drawing.Size(50,100)
    $RLRestoreList.Size = New-Object System.Drawing.Size(485,300)
    $RLRestoreList.SelectionMode = 'One'
    #Get items to add to the list:
    $GameListing = GetBackupGameListing
    foreach ($Game in $GameListing)
    {
        $RLRestoreList.Items.Add($Game.Name)
    }
    $RLRestoreList.Add_Click($SelectedRestoreGame)

    #Crate Restore Button
    $RLRestoreButton = New-Object System.Windows.Forms.Button
    $RLRestoreButton.Location = New-Object System.Drawing.Size(50, 390)
    $RLRestoreButton.Size = New-Object System.Drawing.Size(485,50)
    $RLRestoreButton.Text = $RestoreButtonWhenNoGameSelected
    $RLRestoreButton.Name = "RestoreButton"
    $RLRestoreButton.Enabled = $false
    #Click Event
    $RLRestoreButton.Add_Click($BeginRestore)


    #Add all elements to the Global:ControlLayout:
    $Global:ControlLayout = $RLRestoreButton, $RLBackButton, $RLRestoreList, $RLRestoreLabel
}

    #endregion Form Control Layouts
    #
    ##############################

    ##############################
    #region Display Form with Layouts

#A Function to show the main functions
function ShowMain
{
    if ($Global:MainForm -eq $null)
    {
        BuildMainForm
    }

    CreateMainLayout

    RepopulateMainFormControls

    $Global:MainForm.Text = $ProgramName
    
    #If the form isn't shown:
    if (-not $Global:MainForm.IsHandleCreated) 
    {
        #Show the Form
        [void] $Global:MainForm.ShowDialog()
    }

}


#A Function to show the Backup functions
function ShowBackup
{
    if ($Global:MainForm -eq $null)
    {
        BuildMainForm
    }

    CreateBackupLayout

    RepopulateMainFormControls

    $Global:MainForm.Text = $ProgramName + " - " + $BackupLabel

    #If the form isn't shown:
    if (-not $Global:MainForm.IsHandleCreated) 
    {
        #Show the Form
        [void] $Global:MainForm.ShowDialog()
    }


}

#A Function to show the Restore functions
function ShowRestore
{
    if ($Global:MainForm -eq $null)
    {
        BuildMainForm
    }

    CreateRestoreLayout

    RepopulateMainFormControls

    $Global:MainForm.Text = $ProgramName + " - " +  $RestoreLabel 

    #If the form isn't shown:
    if (-not $Global:MainForm.IsHandleCreated) 
    {
        #Show the Form
        [void] $Global:MainForm.ShowDialog()
    }


}

    #endregion Display Form with Layouts
    #
    ##############################

    ##############################
    #region Operations

    
#A function to get the game listing
Function GetGameListing
{

    $Global:GameList = (Get-ChildItem -Directory $SaveRoot | where {$_.Name -ne $BackupFolderName})

    return $Global:GameList

}

    
#A function to get the game listing
Function GetBackupGameListing
{

    $Global:GameList = (Get-ChildItem -Directory $BackupRoot)

    return $Global:GameList

}

$RestoreOperation =
{
    ShowRestore
}

$BackupOperation = 
{
    ShowBackup
}

$ReturnToMain =
{
    ShowMain
}

$SelectedBackupGame =
{

    $BackupButton = $null

    #Find the control that is named "BackupButton"
    foreach($Control in $global:MainForm.Controls)
    {
        if ($Control.Name -eq "BackupButton")
        {
            $BackupButton = $Control
        }
    }


    $ListBox = $null

    #Find the control that is named "BackupList"
    foreach($Control in $global:MainForm.Controls)
    {
        if ($Control.Name -eq "BackupList")
        {
            $ListBox = $Control
        }
    }
    
    #Set GameName to the selected Item
    $GameName = $ListBox.SelectedItem

    if ($GameName -eq $null)
    {
       $BackupButton.Enabled = $false
       $BackupButton.Text = "$BackupButtonWhenNoGameSelected"
    }
    else
    {
        #Enable Backup button and update its text:
        $BackupButton.Enabled = $true
        $BackupButton.Text = "$BackupButtonWhenGameSelected '$GameName'"


        foreach ($Game in $Global:GameList)
        {
            if ($Game.Name -eq $GameName)
            {
                #Set the game to work with:
                $Global:SelectedGame = $Game
            }
        }

    }

}

$BeginBackup =
{
    #Get the timestamp:
    $Timestamp = (Get-Date).ToString("- dd-MM-yyyy.hh-mm-ss.fff")

    #Build the Backup Folder Name:
    $BackupFolderName = $BackupRoot + $Global:SelectedGame.Name + " " + $TimeStamp + "\"

    try
    {
        #Back up selected Game:
        copy-item $Global:SelectedGame.FullName -Destination $BackupFolderName -Recurse -ErrorAction Stop

        [System.Windows.Forms.MessageBox]::Show("'$Global:SelectedGame'`r`n$WasBackedUp`r`n'$Global:SelectedGame $TimeStamp'",$Success,'Ok')

        #Return to Main screen.
        ShowMain
    }
    catch
    {
        [System.Windows.Forms.MessageBox]::Show("'$Global:SelectedGame'`r`n$WasNotBackedUp`r`n'$Global:SelectedGame $TimeStamp'`r`n$Because`r`n$_`r`n`r`n$ContactSupport.",$BackupFailed,'Ok','Error')
    }



}

$SelectedRestoreGame =
{
    $RestoreButton = $null

    #Find the control that is named "RestoreButton"
    foreach($Control in $global:MainForm.Controls)
    {
        if ($Control.Name -eq "RestoreButton")
        {
            $RestoreButton = $Control
        }
    }


    $ListBox = $null

    #Find the control that is named "RestoreList"
    foreach($Control in $global:MainForm.Controls)
    {
        if ($Control.Name -eq "RestoreList")
        {
            $ListBox = $Control
        }
    }

    #Make the game name the selected Item:
    $GameName = $ListBox.SelectedItem

    if ($GameName -eq $null)
    {
       $RestoreButton.Enabled = $false
       $RestoreButton.Text = "$RestoreButtonWhenNoGameSelected"
    }
    else
    {
        #Enable Restore button and update its text:
        $RestoreButton.Enabled = $true
        $RestoreButton.Text = "$RestoreButtonWhenGameSelected '$GameName'"


        foreach ($Game in $Global:GameList)
        {
            if ($Game.Name -eq $GameName)
            {
                #Set Selected Game:
                $Global:SelectedGame = $Game
            }
        }

    }

}

$BeginRestore =
{
    #Regex Pattern for the timestamp (Based on the $BeginBackup pattern for date):
    $RegexTimeStampPattern = "\s-\s\d{2}-\d{2}-\d{4}.\d{2}-\d{2}-\d{2}.\d{3}"

    #Get the name of the game to replace by replacing the timestamp in the folder name with nothing:
    $NameOfGameToReplace = ($Global:SelectedGame.Name).ToString() -Replace $RegexTimeStampPattern, ""

    #Get the path of the Game to Restore:
    $GameToRestore = $Global:SelectedGame.FullName + "\"

    #Get the path of the game to replace:
    $GameToReplace = $SaveRoot + $NameOfGameToReplace + "\"

    $Overwrite = "No"

    #If the Game to replace exists:
    if (Test-Path $GameToReplace)
    {
        #Warn the user it will be overwritten and ask how they want to proceed:
        $Overwrite = [System.Windows.Forms.MessageBox]::Show("$BackedUpGame`r`n'$Global:SelectedGame'`r`n`r`n$WillOverWrite`r`n'$NameOfGameToReplace'`r`n`r`n$ActionCannotBeUndone`r`n`r`n$AreYouSure",$Warning,'YesNo', 'Warning')
    
    }
    else
    {
        $Overwrite = "Yes"
    }

    
    if ($Overwrite -eq "Yes")
    {
        if (Test-Path $GameToReplace)
        {

            try
            {
                #Remove the game to replace
                Remove-Item -Path $GameToReplace -Recurse -Force -ErrorAction Stop

            }
            catch
            {
                [System.Windows.Forms.MessageBox]::Show("'$GameToReplace'`r`n`$CouldNotBeRemoved`r`n$_`r`n`r`n$ContactSupport",$DeleteFailed,'Ok','Error')

                return
            }
        }
    }
    else
    {
        #Do nothing:
        return
    }


    try
    {
        #Copy the backed up game to the new location:
        copy-item $GameToRestore -Destination $GameToReplace -Recurse -ErrorAction Stop

        [System.Windows.Forms.MessageBox]::Show("'$NameOfGameToReplace'`r`n$WasRestoredFrom`r`n'$Global:SelectedGame'",$Success,'Ok')

        ShowMain

    }
    Catch
    {
        [System.Windows.Forms.MessageBox]::Show("'GameToReplace' $CouldNotBeCopied '$GameToReplace'`r`n`$Because`r`n$_`r`n`r`n$ContactSupport ",$CopyFailed,'Ok','Error')

        return

    }

}


    #endregion Operations
    #
    ##############################

#endregion Functions
#
##############################

##############################
#region Main Program

ShowMain

#endregion Main Program
#
##############################
