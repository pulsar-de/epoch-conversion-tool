--[[

    Epoch Conversion Tool (ECT)

        Author:       Benjamin Kupka
        License:      GNU GPLv3
        Environment:  wxLua-2.8.12.3-Lua-5.1.5-MSW-Unicode

]]


-------------------------------------------------------------------------------------------------------------------------------------
--// PATH CONSTANTS //---------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// import path constants
dofile( "data/cfg/constants.lua" )

-------------------------------------------------------------------------------------------------------------------------------------
--// IMPORTS //----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// lib path
package.path = ";./" .. LUALIB_PATH .. "?.lua" ..
               ";./" .. CORE_PATH .. "?.lua"

package.cpath = ";./" .. CLIB_PATH .. "?.dll"

--// libs
local wx   = require( "wx" )
local tool = require( "tool" )

-------------------------------------------------------------------------------------------------------------------------------------
--// TABLE LOOKUPS //----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

local tool_LoadTable = tool.LoadTable
local tool_SaveTable = tool.SaveTable
local tool_FormatSeconds = tool.FormatSeconds

-------------------------------------------------------------------------------------------------------------------------------------
--// BASICS //-----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

local app_name         = "ECT"
local app_name_long    = "Epoch Conversion Tool"
local app_version      = "v0.1"
local app_copyright    = "Copyright (C) " .. os.date( "%Y" ) .. " by Benjamin Kupka"
local app_license      = "GNU General Public License Version 3"
local app_env          = "Environment: " .. wxlua.wxLUA_VERSION_STRING
local app_build        = "Built with: "..wx.wxVERSION_STRING

local app_width        = 237
local app_height       = 172

--// files
local file_tbl = {
    --// ressources
    [ 1 ] = RES_PATH .. "GPLv3_160x80.png",
    [ 2 ] = RES_PATH .. "osi_75x100.png",
    [ 3 ] = RES_PATH .. "appicon_16x16.png",
    [ 4 ] = RES_PATH .. "appicon_32x32.png",
    [ 5 ] = RES_PATH .. "appicon_64x64.png",
    [ 6 ] = RES_PATH .. "btn_20x14.png",
}
--// fonts
local font_default      = wx.wxFont( 10, wx.wxMODERN, wx.wxNORMAL, wx.wxNORMAL, false, "Candara" )
local font_default_bold = wx.wxFont( 12, wx.wxMODERN, wx.wxNORMAL, wx.wxFONTWEIGHT_BOLD, false, "Candara" )
local font_terminal     = wx.wxFont( 10, wx.wxMODERN, wx.wxNORMAL, wx.wxFONTWEIGHT_BOLD, false, "Consolas" )
local font_about_normal = wx.wxFont( 10, wx.wxMODERN, wx.wxNORMAL, wx.wxNORMAL, false, "Candara" )
local font_about_bold   = wx.wxFont( 12, wx.wxMODERN, wx.wxNORMAL, wx.wxFONTWEIGHT_BOLD, false, "Candara" )

--// controls
local control, di, result
local frame, panel

--// functions
local show_error_window
local check_files_exists
local make_num_array
local show_about_window
local show_window_1, show_window_2, show_window_3

--// for the file integrity check
local exec = true

-------------------------------------------------------------------------------------------------------------------------------------
--// STRINGS //----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// menu
local msg_menu_menu         = "Menu"
local msg_menu_about        = "About"
local msg_menu_about_status = "Informations about"
local msg_menu_close        = "Close"
local msg_menu_close_status = "Close Programm"

--// buttons
local msg_button_close      = "Close"
local msg_button_ok         = "OK"
local msg_button_copy       = "Copy"

--// etc
local msg_error_1           = "Error"
local msg_closing_program   = "Files that are necessary to start the program are missing.\nThe program will be closed.\n\nPlease read the log file."
local msg_really_close      = "Really close?"
local msg_warning           = "Warning"

-------------------------------------------------------------------------------------------------------------------------------------
--// HELPER FUNCS //-----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// error Window
show_error_window = function()
    di = wx.wxMessageDialog(
        wx.NULL,
        msg_closing_program,
        msg_error_1,
        wx.wxOK + wx.wxICON_ERROR + wx.wxCENTRE
    )
    result = di:ShowModal(); di:Destroy()
    if result == wx.wxID_OK then
        if event then event:Skip() end
        if frame then frame:Destroy() end
        exec = false
        return nil
    end
end

--// check if files exists
check_files_exists = function( tbl )
    local missing_file = false
    for k, v in ipairs( tbl ) do
        if type( v ) ~= "table" then
            if not wx.wxFile.Exists( v ) then
                missing_file = true
            end
        else
            if not wx.wxFile.Exists( v[ 1 ] ) then
                missing_file = true
            end
        end
    end
    if missing_file then show_error_window() end
end

make_num_array = function( n )
    local t, x = {}, ""
    for i = 0,  n do
        if string.len( i ) == 1 then x = "0" .. i else x = i end
        t[ i + 1 ] = tostring( x )
        i = i + 1
    end
    return t
end

-------------------------------------------------------------------------------------------------------------------------------------
--// MENUBAR //----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// icons menubar
local bmp_exit_16x16      = wx.wxArtProvider.GetBitmap( wx.wxART_QUIT,        wx.wxART_TOOLBAR )
local bmp_about_16x16     = wx.wxArtProvider.GetBitmap( wx.wxART_INFORMATION, wx.wxART_TOOLBAR )

local menu_item = function( menu, id, name, status, bmp )
    local mi = wx.wxMenuItem( menu, id, name, status )
    mi:SetBitmap( bmp )
    bmp:delete()
    return mi
end

local main_menu = wx.wxMenu()
main_menu:Append( menu_item( main_menu, wx.wxID_ABOUT,  msg_menu_about .. "\tF1", msg_menu_about_status .. " " .. app_name_long, bmp_about_16x16 ) )
main_menu:Append( menu_item( main_menu, wx.wxID_EXIT, msg_menu_close .. "\tF4", msg_menu_close_status, bmp_exit_16x16 ) )

local menu_bar = wx.wxMenuBar()
menu_bar:Append( main_menu, msg_menu_menu )

-------------------------------------------------------------------------------------------------------------------------------------
--// FRAME & PANEL //----------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// app icons (menubar)
local app_icons = wx.wxIconBundle()
app_icons:AddIcon( wx.wxIcon( file_tbl[ 3 ], wx.wxBITMAP_TYPE_PNG, 16, 16 ) )
app_icons:AddIcon( wx.wxIcon( file_tbl[ 4 ], wx.wxBITMAP_TYPE_PNG, 32, 32 ) )

--// frame
frame = wx.wxFrame( wx.NULL, wx.wxID_ANY, app_name .. " " .. app_version, wx.wxPoint( 0, 0 ), wx.wxSize( app_width, app_height ), wx.wxMINIMIZE_BOX + wx.wxSYSTEM_MENU + wx.wxCAPTION + wx.wxCLOSE_BOX + wx.wxCLIP_CHILDREN )
frame:Centre( wx.wxBOTH )
frame:SetMenuBar( menu_bar )
frame:SetIcons( app_icons )
frame:CreateStatusBar( 1 )

--// main panel for frame
panel = wx.wxPanel( frame, wx.wxID_ANY, wx.wxPoint( 0, 0 ), wx.wxSize( app_width, app_height ) )
--panel:SetBackgroundColour( wx.wxColour( 100, 100, 100 ) )
panel:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
panel:SetFont( font_default )

-------------------------------------------------------------------------------------------------------------------------------------
--// DIALOG WINDOWS //---------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// about window
show_about_window = function()
   local size_w = 380
   local size_h = 395
   local di_abo = wx.wxDialog(
        wx.NULL,
        wx.wxID_ANY,
        msg_menu_about .. " " .. app_name_long,
        wx.wxDefaultPosition,
        wx.wxSize( size_w, size_h ),
        wx.wxSTAY_ON_TOP + wx.wxDEFAULT_DIALOG_STYLE - wx.wxCLOSE_BOX - wx.wxMAXIMIZE_BOX - wx.wxMINIMIZE_BOX
    )
    di_abo:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    di_abo:SetMinSize( wx.wxSize( 320, 395 ) )
    di_abo:SetMaxSize( wx.wxSize( 320, 395 ) )

    --// app logo
    local app_logo = wx.wxBitmap():ConvertToImage()
    app_logo:LoadFile( file_tbl[ 5 ] )

    control = wx.wxStaticBitmap( di_abo, wx.wxID_ANY, wx.wxBitmap( app_logo ), wx.wxPoint( 0, 05 ), wx.wxSize( app_logo:GetWidth(), app_logo:GetHeight() ) )
    control:Centre( wx.wxHORIZONTAL )
    app_logo:Destroy()

    --// app name / version
    control = wx.wxStaticText( di_abo, wx.wxID_ANY, app_name_long .. " " .. app_version, wx.wxPoint( 0, 75 ) )
    control:SetFont( font_about_bold )
    control:Centre( wx.wxHORIZONTAL )

    --// app copyright
    control = wx.wxStaticText( di_abo, wx.wxID_ANY, app_copyright, wx.wxPoint( 0, 100 ) )
    control:SetFont( font_about_normal )
    control:Centre( wx.wxHORIZONTAL )

    --// environment
    control = wx.wxStaticText( di_abo, wx.wxID_ANY, app_env, wx.wxPoint( 0, 122 ) )
    control:SetFont( font_about_normal )
    control:Centre( wx.wxHORIZONTAL )

    --// build with
    control = wx.wxStaticText( di_abo, wx.wxID_ANY, app_build, wx.wxPoint( 0, 137 ) )
    control:SetFont( font_about_normal )
    control:Centre( wx.wxHORIZONTAL )

    --// horizontal line
    control = wx.wxStaticLine( di_abo, wx.wxID_ANY, wx.wxPoint( 0, 168 ), wx.wxSize( 275, 1 ) )
    control:Centre( wx.wxHORIZONTAL )

    --// license
    control = wx.wxStaticText( di_abo, wx.wxID_ANY, app_license, wx.wxPoint( 0, 180 ) )
    control:SetFont( font_about_normal )
    control:Centre( wx.wxHORIZONTAL )

    --// GPL logo
    local gpl_logo = wx.wxBitmap():ConvertToImage()
    gpl_logo:LoadFile( file_tbl[ 1 ] )

    control = wx.wxStaticBitmap( di_abo, wx.wxID_ANY, wx.wxBitmap( gpl_logo ), wx.wxPoint( 60, 220 ), wx.wxSize( gpl_logo:GetWidth(), gpl_logo:GetHeight() ) )
    gpl_logo:Destroy()

    --// OSI Logo
    local osi_logo = wx.wxBitmap():ConvertToImage()
    osi_logo:LoadFile( file_tbl[ 2 ] )

    control = wx.wxStaticBitmap( di_abo, wx.wxID_ANY, wx.wxBitmap( osi_logo ), wx.wxPoint( 240, 210 ), wx.wxSize( osi_logo:GetWidth(), osi_logo:GetHeight() ) )
    osi_logo:Destroy()

    --// button "Close"
    local about_btn_close = wx.wxButton( di_abo, wx.wxID_ANY, msg_button_close, wx.wxPoint( 0, size_h - 60 ), wx.wxSize( 60, 20 ) )
    about_btn_close:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    about_btn_close:Centre( wx.wxHORIZONTAL )

    --// event - button "Close"
    about_btn_close:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            di_abo:Destroy()
        end
    )

    --// show dialog
    di_abo:ShowModal()
end

--// window 1
show_window_1 = function()
   local size_w = 247
   local size_h = 200
   local di_1 = wx.wxDialog(
        wx.NULL,
        wx.wxID_ANY,
        "Convert epoch to: human-readable date",
        wx.wxDefaultPosition,
        wx.wxSize( size_w, size_h ),
        wx.wxSTAY_ON_TOP + wx.wxDEFAULT_DIALOG_STYLE - wx.wxCLOSE_BOX - wx.wxMAXIMIZE_BOX - wx.wxMINIMIZE_BOX
    )
    di_1:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    di_1:SetMinSize( wx.wxSize( size_w, size_h ) )
    di_1:SetMaxSize( wx.wxSize( size_w, size_h ) )

    --// date caption
    control = wx.wxStaticText( di_1, wx.wxID_ANY, "Date:", wx.wxPoint( 10, 0 ) )

    --// date
    local datepicker = wx.wxDatePickerCtrl( di_1, wx.wxID_ANY, wx.wxDefaultDateTime,
                                            wx.wxPoint( 10, 15 ), wx.wxSize( 100, 20 ),
                                            wx.wxDP_SHOWCENTURY + wx.wxDP_DROPDOWN ) --wx.wxDP_DROPDOWN )

    --// time caption
    control = wx.wxStaticText( di_1, wx.wxID_ANY, "Time:", wx.wxPoint( 130, 0 ) )

    --// time
    local sTime = wx.wxTextCtrl( di_1, wx.wxID_ANY, "00:00:00", wx.wxPoint( 130, 15 ), wx.wxSize( 65, 20 ), wx.wxTE_READONLY )
    local sHour, sMinutes, sSeconds

    --// time button
    local bmp = wx.wxBitmap( file_tbl[ 6 ], wx.wxBITMAP_TYPE_PNG )
    local btn_set = wx.wxBitmapButton( di_1, wx.wxID_ANY, bmp, wx.wxPoint( 195, 14 ), wx.wxSize( 36, 22 ) )
    btn_set:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    --// event - time button
    btn_set:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            --// dialog size
            local size_w = 170
            local size_h = 120

            --// dialog
            local di = wx.wxDialog(
                wx.NULL,
                wx.wxID_ANY,
                "Time",
                wx.wxDefaultPosition,
                wx.wxSize( size_w, size_h ),
                wx.wxSTAY_ON_TOP + wx.wxDEFAULT_DIALOG_STYLE - wx.wxCLOSE_BOX - wx.wxMAXIMIZE_BOX - wx.wxMINIMIZE_BOX
            )
            di:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
            di:SetMinSize( wx.wxSize( size_w, size_h ) )
            di:SetMaxSize( wx.wxSize( size_w, size_h ) )

            --// hours caption
            control = wx.wxStaticText( di, wx.wxID_ANY, "Hour:", wx.wxPoint( 10, 0 ) )
            --// hours
            local hours = wx.wxChoice(
                di,
                wx.wxID_ANY,
                wx.wxPoint( 10, 20 ),
                wx.wxSize( 45, 20 ),
                make_num_array( 23 )
            )
            hours:Select( 0 )

            --// minutes caption
            control = wx.wxStaticText( di, wx.wxID_ANY, "Minute:", wx.wxPoint( 60, 0 ) )
            --// minutes
            local minutes = wx.wxChoice(
                di,
                wx.wxID_ANY,
                wx.wxPoint( 60, 20 ),
                wx.wxSize( 45, 20 ),
                make_num_array( 59 )
            )
            minutes:Select( 0 )

            --// seconds caption
            control = wx.wxStaticText( di, wx.wxID_ANY, "Second:", wx.wxPoint( 110, 0 ) )
            --// seconds
            local seconds = wx.wxChoice(
                di,
                wx.wxID_ANY,
                wx.wxPoint( 110, 20 ),
                wx.wxSize( 45, 20 ),
                make_num_array( 59 )
            )
            seconds:Select( 0 )

            --// button "OK"
            local btn_ok = wx.wxButton( di, wx.wxID_ANY, msg_button_ok, wx.wxPoint( 0, size_h - 60 ), wx.wxSize( 60, 20 ) )
            btn_ok:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
            btn_ok:Centre( wx.wxHORIZONTAL )

            --// event - button "OK"
            btn_ok:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
                function( event )
                    --// get time
                    sHour    = hours:GetStringSelection( hours:GetCurrentSelection() )
                    sMinutes = minutes:GetStringSelection( minutes:GetCurrentSelection() )
                    sSeconds = seconds:GetStringSelection( seconds:GetCurrentSelection() )
                    sTime:SetValue( sHour .. ":" .. sMinutes .. ":" .. sSeconds )
                    --// kill dialog
                    di:Destroy()
                end
            )
            --// show dialog
            di:ShowModal()
        end
    )

    --// button "calc"
    local btn_calc = wx.wxButton( di_1, wx.wxID_ANY, "Calculate", wx.wxPoint( 10, 45 ), wx.wxSize( 220, 40 ) )
    btn_calc:SetBackgroundColour( wx.wxColour( 0, 0, 0 ) )
    btn_calc:SetForegroundColour( wx.wxColour( 240, 240, 240 ) )
    btn_calc:SetFont( font_default_bold )

    --// epoch time caption
    control = wx.wxStaticText( di_1, wx.wxID_ANY, "Epoch time:", wx.wxPoint( 10, 90 ) )

    --// epoch time
    local epoch_time = wx.wxTextCtrl( di_1, wx.wxID_ANY, "", wx.wxPoint( 10, 105 ), wx.wxSize( 171, 20 ), wx.wxTE_READONLY + wx.wxTE_CENTRE )
    epoch_time:SetFont( font_terminal )
    epoch_time:SetForegroundColour( wx.wxColour( 0, 180, 0 ) )

    --// button "Copy"
    local btn_copy = wx.wxButton( di_1, wx.wxID_ANY, msg_button_copy, wx.wxPoint( 181, 104 ), wx.wxSize( 50, 22 ) )
    btn_copy:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    btn_copy:Disable()

    --// event - button "calc"
    btn_calc:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            -- calculate
            local d = datepicker:GetValue():FormatISODate() -- format wxDateTime to wxString (YYYY-MM-DD)
            local t = sTime:GetValue() -- hh:mm:ss

            local d_year  = d:sub( 1, 4 )
            local d_month = d:sub( 6, 7 )
            local d_day   = d:sub( 9, 10 )
            local t_hour  = t:sub( 1, 2 )
            local t_min   = t:sub( 4, 5 )
            local t_sec   = t:sub( 7, 8 )

            local t_time = os.time( { year = d_year, month = d_month, day = d_day, hour = t_hour, min = t_min, sec = t_sec } )

            epoch_time:SetValue( tostring( t_time ) )
            btn_copy:Enable( true )
        end
    )
    --// button "Close"
    local btn_close = wx.wxButton( di_1, wx.wxID_ANY, msg_button_close, wx.wxPoint( 0, size_h - 60 ), wx.wxSize( 60, 20 ) )
    btn_close:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    btn_close:Centre( wx.wxHORIZONTAL )

    --// event - button "Copy"
    btn_copy:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            -- copy epoch time to clipboard
            local clipBoard = wx.wxClipboard.Get()
            if clipBoard and clipBoard:Open() then
                clipBoard:SetData( wx.wxTextDataObject( epoch_time:GetValue() ) )
                clipBoard:Close()
            end
            btn_copy:Disable()
            wx.wxMessageBox( "Epoch time  " .. epoch_time:GetValue() .. "  successfully copied to the ClipBoard" , "Info", wx.wxOK + wx.wxCENTRE + wx.wxICON_INFORMATION )
            epoch_time:SetValue( "" )
        end
    )

    --// event - button "Close"
    btn_close:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED, function( event ) di_1:Destroy() end )

    --// show dialog
    di_1:ShowModal()
end

--// window 2
show_window_2 = function()
   local size_w = 226
   local size_h = 263
   local di_2 = wx.wxDialog(
        wx.NULL,
        wx.wxID_ANY,
        "Convert epoch to: human-readable date",
        wx.wxDefaultPosition,
        wx.wxSize( size_w, size_h ),
        wx.wxSTAY_ON_TOP + wx.wxDEFAULT_DIALOG_STYLE - wx.wxCLOSE_BOX - wx.wxMAXIMIZE_BOX - wx.wxMINIMIZE_BOX
    )
    di_2:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    di_2:SetMinSize( wx.wxSize( size_w, size_h ) )
    di_2:SetMaxSize( wx.wxSize( size_w, size_h ) )

    --// epoch time caption
    control = wx.wxStaticText( di_2, wx.wxID_ANY, "Epoch time:", wx.wxPoint( 25, 0 ) )

    --// epoch time
    local epoch_time = wx.wxTextCtrl( di_2, wx.wxID_ANY, "", wx.wxPoint( 25, 15 ), wx.wxSize( 170, 20 ), wx.wxTE_PROCESS_ENTER + wx.wxTE_CENTRE, wx.wxTextValidator( wx.wxFILTER_NUMERIC ) )
    epoch_time:SetFont( font_terminal )
    epoch_time:SetMaxLength( 10 )

    --// format caption
    control = wx.wxStaticText( di_2, wx.wxID_ANY, "Format:", wx.wxPoint( 25, 40 ) )
    --// format
    local d_array = {

        "YYYY-MM-DD HH:MM:SS", -- 0
        "DD.MM.YYYY HH:MM:SS", -- 1
        "MM/DD/YY HH:MM:SS",   -- 2
        "DD/MM/YY HH:MM:SS",   -- 3
        "YYYY-MM-DD",          -- 4
        "DD.MM.YYYY",          -- 5
        "MM/DD/YY",            -- 6
        "DD/MM/YY"             -- 7
    }
    local date_format = wx.wxChoice(
        di_2,
        wx.wxID_ANY,
        wx.wxPoint( 25, 55 ),
        wx.wxSize( 170, 20 ),
        d_array
    )
    date_format:Select( 0 )

    --// button "calc"
    local btn_calc = wx.wxButton( di_2, wx.wxID_ANY, "Calculate", wx.wxPoint( 25, 85 ), wx.wxSize( 170, 40 ) )
    btn_calc:SetBackgroundColour( wx.wxColour( 0, 0, 0 ) )
    btn_calc:SetForegroundColour( wx.wxColour( 240, 240, 240 ) )
    btn_calc:SetFont( font_default_bold )
    btn_calc:Disable()

    --// epoch time caption
    control = wx.wxStaticText( di_2, wx.wxID_ANY, "Human-readable date:", wx.wxPoint( 25, 130 ) )

    --// epoch time
    local readable_date = wx.wxTextCtrl( di_2, wx.wxID_ANY, "", wx.wxPoint( 25, 145 ), wx.wxSize( 170, 20 ), wx.wxTE_READONLY + wx.wxTE_CENTRE )
    readable_date:SetFont( font_terminal )
    readable_date:SetForegroundColour( wx.wxColour( 0, 180, 0 ) )

    --// button "Copy"
    local btn_copy = wx.wxButton( di_2, wx.wxID_ANY, msg_button_copy, wx.wxPoint( 24, 167 ), wx.wxSize( 172, 22 ) )
    btn_copy:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    btn_copy:Disable()

    --// button "Close"
    local btn_close = wx.wxButton( di_2, wx.wxID_ANY, msg_button_close, wx.wxPoint( 0, size_h - 60 ), wx.wxSize( 60, 20 ) )
    btn_close:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    btn_close:Centre( wx.wxHORIZONTAL )
    --// event - button "Close"
    btn_close:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED, function( event ) di_2:Destroy() end )

    --// event - button "calc"
    btn_calc:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            btn_calc:Disable()
            local epoch_time  = epoch_time:GetValue()
            local date_format = date_format:GetSelection()

            if date_format == 0 then readable_date:SetValue( os.date( "%Y-%m-%d %X", epoch_time ) ) end
            if date_format == 1 then readable_date:SetValue( os.date( "%d.%m.%Y %X", epoch_time ) ) end
            if date_format == 2 then readable_date:SetValue( os.date( "%m/%d/%Y %X", epoch_time ) ) end
            if date_format == 3 then readable_date:SetValue( os.date( "%d/%m/%Y %X", epoch_time ) ) end
            if date_format == 4 then readable_date:SetValue( os.date( "%Y-%m-%d", epoch_time ) ) end
            if date_format == 5 then readable_date:SetValue( os.date( "%d.%m.%Y", epoch_time ) ) end
            if date_format == 6 then readable_date:SetValue( os.date( "%m/%d/%Y", epoch_time ) ) end
            if date_format == 7 then readable_date:SetValue( os.date( "%d/%m/%Y", epoch_time ) ) end

            btn_copy:Enable( true )
        end
    )

    --// event - epoch_time
    epoch_time:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_TEXT_UPDATED,
        function( event )
            if tonumber( epoch_time:GetValue() ) ~= nil then
                btn_calc:Enable( true )
            else
                epoch_time:SetValue( "" )
                --wx.wxMessageBox( "Only numbers are allowed." , "Info", wx.wxOK + wx.wxCENTRE + wx.wxICON_INFORMATION )
            end
        end
    )

    --// event - date_format
    date_format:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_CHOICE_SELECTED,
        function( event )
            if epoch_time:GetValue() ~= "" then
                btn_calc:Enable( true )
            end
        end
    )

    --// event - button "Copy"
    btn_copy:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            -- copy epoch time to clipboard
            local clipBoard = wx.wxClipboard.Get()
            if clipBoard and clipBoard:Open() then
                clipBoard:SetData( wx.wxTextDataObject( readable_date:GetValue() ) )
                clipBoard:Close()
            end
            wx.wxMessageBox( "Date  " .. readable_date:GetValue() .. "  successfully copied to the ClipBoard" , "Info", wx.wxOK + wx.wxCENTRE + wx.wxICON_INFORMATION )
            btn_copy:Disable()
            btn_calc:Disable()
            epoch_time:SetValue( "" )
            readable_date:SetValue( "" )
        end
    )

    --// show dialog
    di_2:ShowModal()
end

--// window 3
show_window_3 = function()
   local size_w = 226
   local size_h = 293
   local di_3 = wx.wxDialog(
        wx.NULL,
        wx.wxID_ANY,
        "Convert seconds to: Y, D, H, M, S",
        wx.wxDefaultPosition,
        wx.wxSize( size_w, size_h ),
        wx.wxSTAY_ON_TOP + wx.wxDEFAULT_DIALOG_STYLE - wx.wxCLOSE_BOX - wx.wxMAXIMIZE_BOX - wx.wxMINIMIZE_BOX
    )
    di_3:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    di_3:SetMinSize( wx.wxSize( size_w, size_h ) )
    di_3:SetMaxSize( wx.wxSize( size_w, size_h ) )

    --// epoch time caption
    control = wx.wxStaticText( di_3, wx.wxID_ANY, "Seconds:", wx.wxPoint( 25, 0 ) )

    --// epoch time
    local seconds = wx.wxTextCtrl( di_3, wx.wxID_ANY, "", wx.wxPoint( 25, 15 ), wx.wxSize( 170, 20 ), wx.wxTE_PROCESS_ENTER + wx.wxTE_CENTRE, wx.wxTextValidator( wx.wxFILTER_NUMERIC ) )
    seconds:SetFont( font_terminal )
    seconds:SetMaxLength( 15 )

    --// button "calc"
    local btn_calc = wx.wxButton( di_3, wx.wxID_ANY, "Calculate", wx.wxPoint( 25, 43 ), wx.wxSize( 170, 40 ) )
    btn_calc:SetBackgroundColour( wx.wxColour( 0, 0, 0 ) )
    btn_calc:SetForegroundColour( wx.wxColour( 240, 240, 240 ) )
    btn_calc:SetFont( font_default_bold )
    btn_calc:Disable()

    --// time caption
    control = wx.wxStaticText( di_3, wx.wxID_ANY, "Years, Days, Hours, Minutes, Sec:", wx.wxPoint( 25, 90 ) )

    --// time
    local readable_date = wx.wxTextCtrl( di_3, wx.wxID_ANY, "", wx.wxPoint( 25, 105 ), wx.wxSize( 170, 90 ), wx.wxTE_READONLY + wx.wxTE_MULTILINE + wx.wxTE_NO_VSCROLL )
    readable_date:SetFont( font_terminal )
    readable_date:SetForegroundColour( wx.wxColour( 0, 180, 0 ) )

    --// button "Copy"
    local btn_copy = wx.wxButton( di_3, wx.wxID_ANY, msg_button_copy, wx.wxPoint( 24, 197 ), wx.wxSize( 172, 22 ) )
    btn_copy:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    btn_copy:Disable()

    --// button "Close"
    local btn_close = wx.wxButton( di_3, wx.wxID_ANY, msg_button_close, wx.wxPoint( 0, size_h - 60 ), wx.wxSize( 60, 20 ) )
    btn_close:SetBackgroundColour( wx.wxColour( 255, 255, 255 ) )
    btn_close:Centre( wx.wxHORIZONTAL )
    --// event - button "Close"
    btn_close:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED, function( event ) di_3:Destroy() end )

    --// event - button "calc"
    btn_calc:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            btn_calc:Disable()
            local y, d, h, m, s = tool_FormatSeconds( seconds:GetValue() )
            local msg = "Years:   " .. y .. "\n" ..
                        "Days:    " .. d .. "\n" ..
                        "Hours:   " .. h .. "\n" ..
                        "Minutes: " .. m .. "\n" ..
                        "Seconds: " .. s

            readable_date:SetValue( msg )

            btn_copy:Enable( true )
        end
    )

    --// event - seconds
    seconds:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_TEXT_UPDATED,
        function( event )
            if tonumber( seconds:GetValue() ) ~= nil then
                btn_calc:Enable( true )
            else
                seconds:SetValue( "" )
                --wx.wxMessageBox( "Only numbers are allowed." , "Info", wx.wxOK + wx.wxCENTRE + wx.wxICON_INFORMATION )
            end
        end
    )

    --// event - button "Copy"
    btn_copy:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED,
        function( event )
            -- copy epoch time to clipboard
            local clipBoard = wx.wxClipboard.Get()
            if clipBoard and clipBoard:Open() then
                clipBoard:SetData( wx.wxTextDataObject( readable_date:GetValue() ) )
                clipBoard:Close()
            end
            wx.wxMessageBox( "Copied successfully to the ClipBoard:\n\n" .. readable_date:GetValue(), "Info", wx.wxOK + wx.wxCENTRE + wx.wxICON_INFORMATION )
            btn_copy:Disable()
            btn_calc:Disable()
            seconds:SetValue( "" )
            readable_date:SetValue( "" )
        end
    )

    --// show dialog
    di_3:ShowModal()
end

-------------------------------------------------------------------------------------------------------------------------------------
--// PANEL //------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

--// button "1"
local btn_1 = wx.wxButton( panel, wx.wxID_ANY, "Date  -->  Epoch", wx.wxPoint( 0, 0 ), wx.wxSize( 230, 30 ) )
btn_1:SetBackgroundColour( wx.wxColour( 0, 0, 0 ) )
btn_1:SetForegroundColour( wx.wxColour( 240, 240, 240 ) )
btn_1:SetFont( font_default_bold )
--// event - button "1"
btn_1:Connect( wx.wxID_ANY, wx.wxEVT_ENTER_WINDOW, function( event ) frame:SetStatusText( "Click to open window" ) end )
btn_1:Connect( wx.wxID_ANY, wx.wxEVT_LEAVE_WINDOW, function( event ) frame:SetStatusText( "Please make your choice..." ) end )
btn_1:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED, function( event ) show_window_1() end )

--// button "2"
local btn_2 = wx.wxButton( panel, wx.wxID_ANY, "Epoch  -->  Date", wx.wxPoint( 0, 35 ), wx.wxSize( 230, 30 ) )
btn_2:SetBackgroundColour( wx.wxColour( 0, 0, 0 ) )
btn_2:SetForegroundColour( wx.wxColour( 240, 240, 240 ) )
btn_2:SetFont( font_default_bold )
--// events - button "2"
btn_2:Connect( wx.wxID_ANY, wx.wxEVT_ENTER_WINDOW, function( event ) frame:SetStatusText( "Click to open window" ) end )
btn_2:Connect( wx.wxID_ANY, wx.wxEVT_LEAVE_WINDOW, function( event ) frame:SetStatusText( "Please make your choice..." ) end )
btn_2:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED, function( event ) show_window_2() end )

--// button "3"
local btn_3 = wx.wxButton( panel, wx.wxID_ANY, "Seconds  -->  Y, D, H, M, S", wx.wxPoint( 0, 70 ), wx.wxSize( 230, 30 ) )
btn_3:SetBackgroundColour( wx.wxColour( 0, 0, 0 ) )
btn_3:SetForegroundColour( wx.wxColour( 240, 240, 240 ) )
btn_3:SetFont( font_default_bold )
--// events - button "3"
btn_3:Connect( wx.wxID_ANY, wx.wxEVT_ENTER_WINDOW, function( event ) frame:SetStatusText( "Click to open window" ) end )
btn_3:Connect( wx.wxID_ANY, wx.wxEVT_LEAVE_WINDOW, function( event ) frame:SetStatusText( "Please make your choice..." ) end )
btn_3:Connect( wx.wxID_ANY, wx.wxEVT_COMMAND_BUTTON_CLICKED, function( event ) show_window_3() end )


-------------------------------------------------------------------------------------------------------------------------------------
--// MAIN LOOP //--------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------

main = function()
    check_files_exists( file_tbl )
    if exec then
        -- execute frame
        frame:Show( true )
        frame:Connect( wx.wxEVT_CLOSE_WINDOW,
            function( event )
                di = wx.wxMessageDialog( wx.NULL, msg_really_close, msg_warning, wx.wxYES_NO + wx.wxICON_QUESTION + wx.wxCENTRE )
                result = di:ShowModal(); di:Destroy()
                if result == wx.wxID_YES then
                    if event then event:Skip() end
                    if frame then frame:Destroy() end
                end
            end
        )
        -- events - menubar
        frame:Connect( wx.wxID_EXIT, wx.wxEVT_COMMAND_MENU_SELECTED,
            function( event )
                frame:Close( true )
            end
        )
        frame:Connect( wx.wxID_ABOUT, wx.wxEVT_COMMAND_MENU_SELECTED,
            function( event )
                show_about_window( frame )
            end
        )
        -- status text on app start
        frame:SetStatusText( "Please make your choice..." ) -- left
    else
        -- kill frame
        if event then event:Skip() end
        if frame then frame:Destroy() end
    end
end

main(); wx.wxGetApp():MainLoop()