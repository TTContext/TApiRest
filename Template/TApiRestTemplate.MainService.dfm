object ApiRestTemplateService: TApiRestTemplateService
  AllowPause = False
  Dependencies = <
    item
      Name = 'LanmanServer'
      IsGroup = False
    end
    item
      Name = 'Tcpip'
      IsGroup = False
    end>
  DisplayName = 'TApiRestTemplate'
  AfterInstall = ServiceAfterInstall
  AfterUninstall = ServiceAfterUninstall
  OnExecute = ServiceExecute
  OnStart = ServiceStart
  OnStop = ServiceStop
  Height = 480
  Width = 640
end
