object MainForm: TMainForm
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'TApiRestTemplate'
  ClientHeight = 163
  ClientWidth = 299
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  TextHeight = 13
  object ImageList: TImageList
    Height = 24
    Width = 24
    Left = 8
    Top = 8
  end
  object PopupMenu: TPopupActionBar
    Images = ImageList
    OnPopup = PopupMenuPopup
    Left = 36
    Top = 8
    object UrlMenuItem: TMenuItem
      Caption = 'URL'
      OnClick = UrlMenuItemClick
    end
    object Separator01MenuItem: TMenuItem
      Caption = '-'
    end
    object StartMenuItem: TMenuItem
      Caption = 'Start'
      ImageIndex = 0
      OnClick = StartMenuItemClick
    end
    object StopMenuItem: TMenuItem
      Caption = 'Stop'
      ImageIndex = 1
      OnClick = StopMenuItemClick
    end
    object Separator02MenuItem: TMenuItem
      Caption = '-'
      Visible = False
    end
    object TerminateMenuItem: TMenuItem
      Caption = 'Terminate'
      OnClick = TerminateMenuItemClick
    end
  end
  object TrayIcon: TTrayIcon
    Hint = 'TApiRestTemplate'
    PopupMenu = PopupMenu
    Visible = True
    Left = 64
    Top = 8
  end
end
