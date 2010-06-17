# Microsoft Developer Studio Project File - Name="AutoclassC" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 5.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

CFG=AutoclassC - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "AutoclassC.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "AutoclassC.mak" CFG="AutoclassC - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "AutoclassC - Win32 Release" (based on\
 "Win32 (x86) Console Application")
!MESSAGE "AutoclassC - Win32 Debug" (based on\
 "Win32 (x86) Console Application")
!MESSAGE 

# Begin Project
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "AutoclassC - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MD /W3 /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /FD /c
# SUBTRACT CPP /Fr
# ADD BASE RSC /l 0x1009 /d "NDEBUG"
# ADD RSC /l 0x1009 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 ws2_32.lib /nologo /subsystem:console /machine:I386 /out:"Release/Autoclass.exe"

!ELSEIF  "$(CFG)" == "AutoclassC - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Autoclas"
# PROP BASE Intermediate_Dir "Autoclas"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /D "_MBCS" /YX /FD /c
# ADD CPP /nologo /MDd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX"autoclass.h" /FD /c
# ADD BASE RSC /l 0x1009 /d "_DEBUG"
# ADD RSC /l 0x1009 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386 /pdbtype:sept
# ADD LINK32 ws2_32.lib /nologo /subsystem:console /debug /machine:I386 /out:"Debug/Autoclass.exe" /pdbtype:sept
# Begin Special Build Tool
OutDir=.\Debug
SOURCE=$(InputPath)
PostBuild_Cmds=copy $(OutDir)\*.exe ..\testdll
# End Special Build Tool

!ENDIF 

# Begin Target

# Name "AutoclassC - Win32 Release"
# Name "AutoclassC - Win32 Debug"
# Begin Source File

SOURCE=.\autoclass.c
# End Source File
# Begin Source File

SOURCE=.\getparams.c
# End Source File
# Begin Source File

SOURCE=.\globals.c
# End Source File
# Begin Source File

SOURCE=.\init.c
# End Source File
# Begin Source File

SOURCE=".\intf-extensions.c"
# End Source File
# Begin Source File

SOURCE=".\intf-influence-values.c"
# End Source File
# Begin Source File

SOURCE=".\intf-reports.c"
# End Source File
# Begin Source File

SOURCE=".\intf-sigma-contours.c"
# End Source File
# Begin Source File

SOURCE=".\io-read-data.c"
# End Source File
# Begin Source File

SOURCE=".\io-read-model.c"
# End Source File
# Begin Source File

SOURCE=".\io-results-bin.c"
# End Source File
# Begin Source File

SOURCE=".\io-results.c"
# End Source File
# Begin Source File

SOURCE=".\matrix-utilities.c"
# End Source File
# Begin Source File

SOURCE=".\model-expander-3.c"
# End Source File
# Begin Source File

SOURCE=".\model-multi-normal-cn.c"
# End Source File
# Begin Source File

SOURCE=".\model-single-multinomial.c"
# End Source File
# Begin Source File

SOURCE=".\model-single-normal-cm.c"
# End Source File
# Begin Source File

SOURCE=".\model-single-normal-cn.c"
# End Source File
# Begin Source File

SOURCE=".\model-transforms.c"
# End Source File
# Begin Source File

SOURCE=".\model-update.c"
# End Source File
# Begin Source File

SOURCE=.\predictions.c
# End Source File
# Begin Source File

SOURCE=.\prints.c
# End Source File
# Begin Source File

SOURCE=".\search-basic.c"
# End Source File
# Begin Source File

SOURCE=".\search-control-2.c"
# End Source File
# Begin Source File

SOURCE=".\search-control.c"
# End Source File
# Begin Source File

SOURCE=".\search-converge.c"
# End Source File
# Begin Source File

SOURCE=.\statistics.c
# End Source File
# Begin Source File

SOURCE=".\struct-class.c"
# End Source File
# Begin Source File

SOURCE=".\struct-clsf.c"
# End Source File
# Begin Source File

SOURCE=".\struct-data.c"
# End Source File
# Begin Source File

SOURCE=".\struct-matrix.c"
# End Source File
# Begin Source File

SOURCE=".\struct-model.c"
# End Source File
# Begin Source File

SOURCE=".\utils-math.c"
# End Source File
# Begin Source File

SOURCE=.\utils.c
# End Source File
# End Target
# End Project
