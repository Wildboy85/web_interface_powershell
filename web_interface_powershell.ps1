 
########################## ps_web_interface.ps1 ##############################
# 2017-09-17
# for inner html to work, you need to install office 2013
# since office 2013 is not installed on a server, i will make it work without it (for frame clearing)

# 2017-02-11
# added id to buttons because in microsoft edge, name was not the same as id

# 2016-04-03
# added some innerhtml to clear frames properly

# 2016-04-02
# First draft of the powershell version of my web interface for network administrators

### manifest
# powershell web interface for a network administrator
# par: serge.fournier(a)hotmail.com
# 2016-03-28

### DEscription:
# A powershell script to use internet explorer as interface for more powershell scripts
# It start internet explorer, divide it in 3 frames (flef, fmid and fbot)
# In the left frame, there is control buttons
# In middle frame (up) you can input some data to be processed
# (it's just some textbox in html that return their results to powershell)
# In the bottom frame, you can display the processing or the results of your scripts

### requirements
# because this script is not signed
# (this will allow unsigned local powershell scripts to run)
#   windows 7
#     Set-ExecutionPolicy RemoteSigned #################################
#   windows 10
#     Set-ExecutionPolicy -scope CurrentUser RemoteSigned ##############
#   run it in powershell ISE interface
#

### powershell error in english
# Update-Help -UICulture en-US
# [Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'

# variables typed

add-type @"
public struct oieparamin01 
    {
    public int height01;
    public int width01;
    public string[] arabutnam;
    }
"@

add-type @"
public struct oieparamout01
    {
    public object oie;
    public object flef;
    public object fmid;
    public object fbot;
    }
"@

add-type @"
public struct dynamicformparamout
    {
    public string[] arabutnam;
    public string[] araresults;
    }
"@

###########################################
#   wait for com object OIE to be ready
###########################################
function isoieready($oie)
    {
    $millisec = 50
    While (($oie.ReadyState -ne 4) -and ($oie.hwnd -ne $null)) { Start-Sleep -Milliseconds $millisec}
    While (($oie.busy) -and ($oie.hwnd -ne $null)) { Start-Sleep -Milliseconds $millisec}
    return $oie.hwnd
    }

##########################################
#   internet explorer
##########################################
function makenewOIE($oieparamin01)
    {
    
    $oieparamout01 = new-object oieparamout01;
    
    # start ie object
    $oie = new-object -com InternetExplorer.Application
    $oie.FullScreen = $False

    # wait for a time then fatal error if iexplore does not get created
    $timeout01 = 0
    #$ieStatus01 = Get-ProcessWithOwner iexplore

    $oIE.left=0 # window position
    $oIE.top = 0 # and other properties
    $oIE.height = $oieparamin01.height01
    $oIE.width = $oieparamin01.width01
    $oIE.menubar = 1 #=== no menu
    $oIE.toolbar = 1
    $oIE.statusbar = 1
    $oIE.RegisterAsDropTarget = $True
    $oie.Navigate("about:blank")
    $oie.document.title = "Powershell Web Interface"

    # calculate for ie to take all screen but a small lane of 10% up top
    # get screen resolution
    # work only in powershell ISE or as admin (presumably)
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")            
    [void] [Reflection.Assembly]::LoadWithPartialName("System.Drawing")            
    $Screens = [system.windows.forms.screen]::AllScreens  
 
    $DeviceName = $Screens[0].DeviceName            
    $oiewid  = $Screens[0].Bounds.Width            
    $oiehei  = $Screens[0].Bounds.Height            
    $IsPrimary = $Screens[0].Primary            
 
    $sizwidpercent = 100
    $sizheipercent = 95
    $loswid = 100-$sizwidpercent
    $loshei = 100-$sizheipercent
    $newwid = $oiewid*$sizwidpercent*.01
    $newhei = $oiehei*$sizheipercent*.01
    # this stuff work in ISE console but not outside of it
    try {$oie.document.parentwindow.resizeto($newwid,$newhei)} catch {}
    $newx = $oiewid * $loswid * .01 /2
    $newy = $oiehei * ($loshei/2) * .01 /2
    try {$oie.document.parentwindow.moveto($newx, $newy)} catch {}
    $oie.addressbar=$false 
 
    $oie.visible = $true

    $dummy = isoieready($oie)

    $doctit = "Powershell Web Interface"

    $h = "<HTML>"
    $h+="<HEAD><TITLE>" + $doctit + "</TITLE>"
    $h+="<meta content=""text/html; charset=utf-8"" http-equiv=""Content-Type"">"
    $h+="<meta http-equiv=""X-UA-Compatible"" content=""IE=8"">"
    $h+="</HEAD>"
    $h+="<FRAMESET id='main' COLS=""13%, *"">"
    $h+="<FRAME SRC=""About:Blank"" NAME=""left"" id=""left"">"
    $h+="<frameset id='main2' rows=""30%,70%"">"
    $h+="<FRAME SRC=""About:Blank"" NAME=""middle"" id=""middle"">"
    $h+="<FRAME SRC=""About:Blank"" NAME=""bottom"" id=""bottom"">"
    $h+="</FRAMESET>"
    $h+="</frameset>"
    $h+="</HTML>"

    $oIE.document.documentelement.innerhtml = $h
    
    #if (isoieready($oie)) {$oie.document.IHTMLDocument2_write($h)}
    
    #$oie.Navigate('file://C:\win10una1703frapro_home\sources\$oem$\$1\_util\web_interface_powershell\mainmenu.html')
    #$oie.refresh()

    #if (isoieready($oie)) {$oie.document.IHTMLDocument2_write("<br>")}

    $dummy = isoieready($oie)

    # get ie version by register base
    # https://gallery.technet.microsoft.com/scriptcenter/Servers-Inventory-report-97da5709

    # get ie file version, 9 and before does not act like 10 and after for frame objects
    $fileversion = [System.Diagnostics.FileVersionInfo]::GetVersionInfo("C:\program files\internet explorer\iexplore.exe").FileVersion
    $finddot = $fileversion.indexof(".")
    $fileversion2 =  $fileversion.substring(0,$finddot)

    #start-sleep -m 100

    if (($fileversion2 -eq "10") -or ($fileversion2 -eq "11") -or ($fileversion2 -eq "12")) 
        {
        
        #$flef = $oie.parent.document.getElementByid("left").document.documentelement # not working in frame...
        
        if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " Before getting frames" | Out-File $filnam01 -append}
        
        if (isoieready($oie)) {$flef = $oie.parent.document.getElementByid("left").contentdocument}
        if (isoieready($oie)) {$fmid = $oie.parent.document.getElementByid("middle").contentdocument}
        if (isoieready($oie)) {$fbot = $oie.parent.document.getElementByid("bottom").contentdocument}
        
        #if (isoieready($oie)) {$flef = $oie.parent.document.getElementByid("left").document.contentdocument}
        #                  set crefra = oie.parent.document.getElementByid(ffranam).contentdocument
        
        #$flef = $oie.parent.document.getElementByid("left").contentdocument
        
        if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " After getting frames" | Out-File $filnam01 -append}
        #set crefra = oie.parent.document.getElementByid(ffranam).contentdocument
        #break
        }
    else
        {
        if (isoieready($oie)) {$flef = $oie.document.frames("left").document}
        if (isoieready($oie)) {$fmid = $oie.document.frames("middle").document}
        if (isoieready($oie)) {$fbot = $oie.document.frames("bottom").document}
        }

    ### buttons to display in web interface
    #$fmid.IHTMLDocument2_write("arabutnam of 0: " + $arabutnam[0])

    $h = "<html><body>"
    #$h+="<body background=""" & basedir & "LOGO-background.jpg"">")
    $h+="<h3><span class=SpellE>" + $maitit + "</span></h3>"
    $h+="<form name='form1'>"
    
    if (isoieready($oie)) {$flef.IHTMLDocument2_write($h)}

    $i = 0
    foreach ($element in $arabutnam)
        {
        #$fmid.IHTMLDocument2_write($element)
        
        $h = "<input type=""hidden"" id=""" + $arabutnam[$i] + """ name=""" + $arabutnam[$i] + """ value=""0"">"
        $h+= "<input type=""button"" style=""height:50px;font-size:14px;white-space: normal;width:100%;"" value=""" + $arabutdes[$i] + """ " #name=""" + $arabutnam[$i] + """ 
        $h+= "onclick=""" + $arabutnam[$i] + ".value=1"""
        
        $i2=$i
        if ($i -gt $arabutnam.getupperbound(0))
            {
            $i2=$arabutnam.getupperbound(0)
            }
        else
            {
            $a=$aradepnam[$i2]
            }
        if ($a -ne $lasdep)
            {
            #=== new departement name
            if (isoieready($oie)) {$flef.IHTMLDocument2_write("<br>" + $a + "<br>")}
            $lasdep=$a
            }
        $h+=" style=""background-color: #" + $aradepcol[$i2] + "; color: #000000;""><br>"
        if (isoieready($oie)) {$flef.IHTMLDocument2_write($h)}
        $i=$i+1
        }

    $h = "</form>" + "</body>" + "</html>"
    if (isoieready($oie)) {$flef.IHTMLDocument2_write($h)}

    $oieparamout01.oie = $oie
    $oieparamout01.flef = $flef
    $oieparamout01.fmid = $fmid
    $oieparamout01.fbot = $fbot

    return $oieparamout01

    }
################################################
#   dynamicform in html
################################################

function dynamicform()
    {
    #dynamicform($pardescription, $parname, $pardefault, $partype, $parbuttons, $parvalidation, $parsuffix)
    if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " dynamic form generation" | Out-File $filnam01 -append}
    
    $dynamicformparamout01 = new-object dynamicformparamout;
    #$global:resbutstr = ""
    $resbut = 0
    $validation = 0
    $result= $null
    
    do
        {
        if ($validation -eq 0)
            {
            $h= "<body>"
            $h+= "<html>"
            
            # focus on a textbox (usually the first one)
            $h+= "<BODY onLoad=""document.form01." + $parname[0] + ".focus()"">"

            $h+= "<div class=MsoNormal align=center style='text-align:center'>"
            $h+= "</div>"
            $h+= "<form name=form01>"
            
            # input fields/textbox
            $i = 0
            foreach ($element in $parname)
                {
                $h+= $parprefix[$i] + ": "
                $h+= "<input type=" + $partype[$i] + ""
                $h+= " id=" + $parname[$i]
                $h+= " NAME=""" + $parname[$i] + """ size=""20"" value=""" + $pardefault[$i] + """ onKeypress=""return event.keyCode!=13"""

                $col = "blue"
                
                $h+= "&nbsp; <b><span style='color:" + $col + "'>&nbsp" + $parsuffix[$i] + "</span></b><br style='mso-special-character:line-break'>"

                $h+= "<![if !supportLineBreakNewLine]><style='mso-special-character:line-break'>"
                $h+= "<![endif]></p>"
                $i++
                }
            
            # button ok and cancel
            $i = 0
            foreach ($element in $parbuttons)
                {
                $typ01 = "button"
                $h+= "<input type=""hidden"" id=""" + $element + """ name=""" + $element + """ value=""0"">"
                $h+= "<input type=""" + $typ01 + """ value=""&nbsp;" + $element + "&nbsp;"" "
                $h+= "onclick=""" + $element + ".value=1"">"
                #$h+= "<input type=""" + $typ01 + """ name=""" + $element + """ value=""&nbsp;" + $element + "&nbsp;"">"
                $h+= "&nbsp&nbsp&nbsp"
                $i++
                #$h = "<input type=""hidden"" id=""" + $arabutnam[$i] + """ name=""" + $arabutnam[$i] + """ value=""0"">"
                #$h+= "<input type=""button"" style=""height:50px;font-size:14px;width:100%;"" value=""" + $arabutdes[$i] + """ " #name=""" + $arabutnam[$i] + """ 
                #$h+= "onclick=""" + $arabutnam[$i] + ".value=1"""
                }
            
            $h+= "</div>"
            $h+= "</form>"
            $h+= "</body>"
            $h+= "</html>"
            #IF (isoieready($oie)) {$fmid.IHTMLDocument2_write($h)}
            
            IF (isoieready($oie)) {$fmid.IHTMLDocument2_write($h)}
        }
        else 
        {
            # dont display stuff again, wait for ok to click
        
        }
        start-sleep -m 50
        
        # button dynamic form check
        foreach ($element in $parbuttons)
            {
            if ($global:resbutstr -eq "")
                {
                if (isoieready($oie)) {$resbut = $fmid.getElementByID($element).value}
                if ($resbut -ne 0) {$global:resbutstr = $element}
                }
            }
        
        # buttons left frame check

        if ($event01 -eq 0)
            {
            & $Actionflef
            $resbutstr = $global:resbutstr
            try {$resbutstr = $resbutstr.tolower()}catch{}
            }
        else
            {
            $resbutstr = $global:resbutstr
            try {$resbutstr = $resbutstr.tolower()}catch{}
            }
            
        if ($global:resbutstr -ne "")
            {
            if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + $global:resbutstr + " was pressed" | Out-File $filnam01 -append}

            # validate result and reloop if something is wrong
            }
        
        # will return result after sub
        $dynamicformparamout01.arabutnam = $global:resbutstr

        if ($global:resbutstr -eq "ok")
            {
            # validate results
            
            
            $i = 0
            $result = $null
            foreach ($element in $parname)
                {
                $resultdummy = ""
                if (isoieready($oie)) {$resultdummy = $fmid.getElementByID($parname[$i]).value}
                [string[]]$result+= $resultdummy
                
                #if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " stuff: " + $i + " " + $result[$i]| Out-File $filnam01 -append}
                $i++
                }
            
            }
            else
            {
            # something else than OK was pressed
            $result = $null
            }
        # everything is valid, even empty strings in html boxes
        $validation=1
        } until ((($global:resbutstr -ne "") -and ($validation -eq 1)) -or ($oie.hwnd -eq $null))
    
    # reset ok and cancel buttons value to 0
    foreach ($element in $parbuttons)
        {
        if (isoieready($oie)) {$fmid.getElementByID($element).value=0}
        }
    
    $dynamicformparamout01.araresults = $result
    return $dynamicformparamout01
    #, $resbutcancel
    }

    
##############################################
#   START
##############################################

# get powershell version
# $PSVersionTable

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$scriptname = split-path -leaf $MyInvocation.MyCommand.Definition
$Logfilename = $scriptname + "_log.txt"
$filnam01 = $scriptPath + "\" + $Logfilename
$logall = 1
$dynamicformparamout01 = new-object dynamicformparamout;
    
if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " START" | Out-File $filnam01}

$maitit = "Powershell Web Interface"

$project01 = "test"
#$project01 = "office365"

# each project have it's own buttons in left frame

if ($project01 -eq "test")
    {
    # buttons to display in internet explorer left frame
    [string[]]$arabutnam="test"
    [string[]]$arabutdes="test something"
    [string[]]$aradepnam="Change"
    [string[]]$aradepcol="cccccc"
    }

if ($project01 -eq "office365")
    {
    # buttons to display in internet explorer left frame
    [string[]]$arabutnam="createlibrary"
    [string[]]$arabutdes="office 365 library creation"
    [string[]]$aradepnam="Change"
    [string[]]$aradepcol="cccccc"
    }
 
# buttons for all projects
$arabutnam+="githubcreatecommit"
$arabutdes+="Github create and commit"
$aradepnam+="Github"
$aradepcol+="cccccc"

$arabutnam+="githubget"
$arabutdes+="Gethub Get"
$aradepnam+="Github"
$aradepcol+="cccccc"

$arabutnam+="info01"
$arabutdes+="Information"
$aradepnam+="all"
$aradepcol+="cccccc"

$arabutnam+="quit01"
$arabutdes+="Quitter"
$aradepnam+="all"
$aradepcol+="cccccc"

# internet explorer interface for powershell
$oieparamin01 = new-object oieparamin01;
$oieparamin01.height01 = 800
$oieparamin01.width01 = 1150
# we call the fonction with a typed/struct variable as parameter, this way we can change the number of parameters dynamically
$oieparamout01 = new-object oieparamout01;
$oieparamout01  = makenewOIE($oieparamin01)
# put the frames in friendly variables names
$oie = $oieparamout01.oie
$flef = $oieparamout01.flef
$fmid = $oieparamout01.fmid
$fbot = $oieparamout01.fbot

#=== make internet explorer the main active window
#a = objShe.AppActivate("http:/// - " & doctit & " - M")
#a = objShe.AppActivate(doctit & " - M")

$usenam = [Environment]::UserName

#$fmid.IHTMLDocument2_write([System.Security.Principal.WindowsIdentity]::GetCurrent().Name + "<br>")

#=== string result for a button press in a frame (lef = left frame, mid = middle frame (up))
$resbutstr=""

$reskeylef=0
$reskeymid=0
$reskeybot=0

#=== we also chek the key presse in each frame
#=== we do this cause we want "enter" key to be used instead of pressing "ok" button with the mouse
#$flef.onkeypress = GetRef("Checklef")
#$fmid.onkeypress = GetRef("Checkmid")
#$fbot.onkeypress = GetRef("Checkbot")

#############################################
#   main loop
#############################################
#events
#http://demay.iut.lr.free.fr/doc/2A/IC1/PowerShell/La%20gestion%20des%20evenements%20sous%20PowerShell.pdf

### this dynamic (code in code) script will check for buttons pressed in left frame (control frame)
$Actionflef = 
    {
 
    foreach ($element in $arabutnam)
        {
        if ($resbutstr -eq "")
            {
                if (isoieready($oie)) 
                    {
                    $resbut = $flef.getElementByID($element).value
                    }
                if ($resbut -eq 1) 
                    {
                    # put button that was pressed in left frame in a global variable
                    $global:resbutstr = $element
                    $flef.getElementByID($element).value = 0
                    #write-host $resbut
                    #write-host $element
                    }
            }
        }
    }
$Actionfmid = 
    {
    # event testing

    #$sender.HTMLDocumentEvents_Event_onmouseup
    
    return $true
    #$Event, $EventSubscriber, $Sender, $SourceEventArgs
    #https://www.w3.org/TR/DOM-Level-2-Events/events.html

    
    #& $event

    }
$Actionfbot = 
    {
    # event testing

    #[System.Windows.Forms.MessageBox]::Show("fbot")
    #try {Get-EventSubscriber -SourceIdentifier "eventclickfbot" | Unregister-Event | out-null} catch {}
    #Unregister-Event -SubscriptionId $eventclickfbot.id
    #foreach ($element in $arabutnam) {if (isoieready($oie)) {$resbut = $fbot.getElementByID($element).value}}
    #Get-EventSubscriber | Unregister-Event
    #return
    }

#https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Get-Keystrokes.ps1

############################ event test flag #################
$event01 = 0
    
#################################################################################
# balloon tip 5 seconde or until $balloon.dispose()
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
$Title = "This is the title"
$Text = "This is the text"
$EventTimeOut = 5

$balloon = New-Object System.Windows.Forms.NotifyIcon
$balloon.Icon = [System.Drawing.SystemIcons]::Information
$balloon.BalloonTipTitle = $Title
$balloon.BalloonTipText = $Text
$balloon.Visible = $True

$balloon.ShowBalloonTip(1)

$balloon.Dispose()

While (($resbutstr –ne "quit01") -and ($oie.hwnd -ne $null))
    {
    start-sleep -m 50

    # check buttons in left frame
    & $Actionflef
    $resbutstr = $global:resbutstr
    try {$resbutstr = $resbutstr.tolower()}catch{}

    $resbut = 0
    #write-host $resbutstr

    ###################################################
    # github create and commit
    ###################################################

    if ($resbutstr -eq "githubcreatecommit")
        {
        $resbutstr = ""
        $resbut = 0

        if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " button githubcreatecommit was clicked" | Out-File $filnam01 -append}

        if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        if (isoieready($oie)) {$Fbot.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        
        $fmid.IHTMLDocument2_write("<br>Github create and commit is not done yet")
        
        $fmid.IHTMLDocument2_write("<br><br>Press any button in left frame to continue...")


        }
    if ($resbutstr -eq "githubget")
        {
        $resbutstr = ""
        $resbut = 0

        if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " button githubcreatecommit was clicked" | Out-File $filnam01 -append}

        # clear frame
        if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        if (isoieready($oie)) {$Fbot.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        
        $fmid.IHTMLDocument2_write("<br>Github get is not done yet")
        
        $fmid.IHTMLDocument2_write("<br><br>Press any button in left frame to continue...")


        }
    if ($resbutstr -eq "test")
        {
        $resbutstr = ""
        $resbut = 0
        # before we go to the dynamic form, we reset left frame button value
        #if (isoieready($oie)) {$flef.getElementByID($resbutstr).value = 0}
        
        # TEST reset button value (unpress the button)

        if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " button TEST was clicked" | Out-File $filnam01 -append}
        
        # clear frame
        if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " clearing frame" | Out-File $filnam01 -append}

        # clear frame
        if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        if (isoieready($oie)) {$Fbot.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        
        # get and validate some parameters

        [string[]]$parprefix="Name of the project to create"
        [string[]]$parname="name01"
        [string[]]$pardefault="helloworld"
        [string[]]$partype="textbox"
        [string[]]$parsuffix="Entrez un numéro de projet"
        
        # parameter number 2 to inputbox
        $parprefix+="stuff to enter"
        $parname+="name02"
        $pardefault+="salutlesamis"
        $partype+="textbox"
        $parsuffix+="ceci est un test"

        [string[]]$parbuttons="ok"
        $parbuttons+="cancel"
        
        $dynamicformparamout01 = dynamicform($parprefix, $parname, $pardefault, $partype, $parbuttons, $parsuffix, $arabutnam)
        
        # all value returned by the web form are in $result array
        
        $i=0
        
        if ($dynamicformparamout01.arabutnam -eq "ok")
            {
            ##############################################
            #   do some stuff
            #   1 create folder structure
            #   2 create a ldap user
            #   3 create ldap group
            #   4 create a office 365 site and library
            #   5 extract documents from office 365 based on terms and major version
            ##############################################            
            
            # clear frame
            if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        
            $h = ""
            $i = 0
                    
            $h+= "<table width=""100%"" BORDERCOLOR=""black"" class=MsoTableGrid border=1 CELLSPACING=0 cellpadding=2 style='border-collapse:collapse;border: 1px solid black'>"
            
            foreach ($element in $dynamicformparamout01.araresults)
                {
                $h+= "<tr>"
                # display results in fbot frame
                $h += "<td>" + $parprefix[$i] + "</td>"
                $h += "<td>" + $dynamicformparamout01.araresults[$i] + "</td>"
                if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " stuff2: " + $i + " " + $dynamicformparamout01.araresults[$i]| Out-File $filnam01 -append}
                $h+= "</tr>"
                $i++
                }
            
            $h+="</table>"
            IF (isoieready($oie)) {$fmid.IHTMLDocument2_write($h)}
            
            $resbutstr = ""
            $resbut = 0

            }
        elseif ($dynamicformparamout01.arabutnam -eq "cancel")
            {
            if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " another button was pressed: " + $dynamicformparamout01.arabutnam| Out-File $filnam01 -append}
            
            # reset button value for left frame (unclick the button)
            #if (isoieready($oie)) {$flef.getElementByID($resbutstr).value = 0}
            $resbutstr = ""
            $resbut = 0 
            if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
            if (isoieready($oie)) {$Fbot.IHTMLDocument2_open("ABOUT:BLANK") | out-null}

            }
        else
            {
            if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " another button was pressed: " + $dynamicformparamout01.arabutnam| Out-File $filnam01 -append}
            # since another button on left frame was pressed
            # no action is done here, and the button stay pressed until it's action is done
            # clear all frames
            if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
            if (isoieready($oie)) {$Fbot.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
            
            $resbutstr = $dynamicformparamout01.arabutnam
            
            }
        
 
        }

    if ($resbutstr -eq "office365")
        {
        
        # secure password example TO ENTER PASSWORD
        function str([Security.SecureString]$s) 
            {
            return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($s))
            }
        }

    if ($resbutstr -eq "info01")
        {
        $resbutstr = ""
        $resbut = 0
        
        #if (isoieready($oie)) {$flef.getElementByID($resbutstr).value = 0}
        if (isoieready($oie)) {$FMID.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        if (isoieready($oie)) {$Fbot.IHTMLDocument2_open("ABOUT:BLANK") | out-null}
        
        # main action for this button
        $h = "<br>Powershell web interface<br>"
        $h+= "<br>This program was made by: sergefournier(@)hotmail.com<br>"
        $h+= "<br>2016-03-04 added some innerhtml to clear frames<br>"
        $h+= "<br>2016-03-04 removed innerhtml cause it does not work without office installed<br>"
        IF (isoieready($oie)) {$fmid.IHTMLDocument2_write($h)}
        
        }
    
    # system string does not have tolower method so it generate an error
    #try {$resbutstr = $resbutstr.tolower()} catch {}
    
    }

$dummy = isoieready($oie)

if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " oie state: " + $dummy | Out-File $filnam01 -append}

if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " button pressed: " + $resbutstr | Out-File $filnam01 -append}

if ($logall=1) {(Get-Date -Format "yyyy-MM-dd HH:mm:ss") + " END quit was pressed or internet explorer closed" | Out-File $filnam01 -append}

# end of program, quit was pressed or OIE handle is null
if (isoieready($oie)) 
    {
    #$fmid.IHTMLDocument2_write("EXIT " + $resbutlefstr + "<br>")
    
    Get-EventSubscriber | Unregister-Event | out-null
    #try {Get-EventSubscriber -SourceIdentifier "clickflef" | Unregister-Event | out-null} catch {}
    #try {Get-EventSubscriber -SourceIdentifier "clickfmid" | Unregister-Event | out-null} catch {}
    #try {Get-EventSubscriber -SourceIdentifier "clickfbot" | Unregister-Event | out-null} catch {}    
    $oie.quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($oie) | out-null
    }

############## REFERENCE 
function Check-NewGmail {
  param(
    [String]$Email = (Read-Host "Enter your email"),    
    [Security.SecureString]$Password = (Read-Host "Enter email password" -as)
  )

  function str([Security.SecureString]$s) {
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto(
      [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    )
  }
  $com = New-Object -com MSXML2.XMLHTTP.3.0
  $com.open('GET', $('https://' + $Email + ':' + `
             (str $Password) + '@mail.google.com/mail/feed/atom'), $false)
  $com.setRequestHeader('Content-Type', 'application/x-www-from-urlcoded')
  $com.send()

  $com.responseText -match 'fullcount>\d+' | Out-Null; $res = ($matches[0] -split '>')[1]
  Write-Host You have $res new letter`(s`).
}

    
#Remove-Variable $oie

 
 

