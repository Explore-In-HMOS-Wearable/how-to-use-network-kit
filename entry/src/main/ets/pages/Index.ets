import PermissionsUtil from '../utils/PermissionsUtil';

@Builder
export function IndexBuilder() {
  Index();
}

@Entry
@Component
struct Index {
  pageStack : NavPathStack = new NavPathStack();
  private uiContext = this.getUIContext();
  private realContext = this.uiContext.getHostContext()

  aboutToAppear(): void {
    PermissionsUtil.requestPermissions(['ohos.permission.INTERNET'],this.realContext!)
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button('Http Request').onClick(() => {
          this.pageStack.pushPathByName('HttpPage', null, false);
        })
        Blank().height(10)
        Button('Web Socket Test').onClick(() => {
          this.pageStack.pushPathByName('WebSocketTestPage', null, false);
        })
        Blank().height(10)
        Button('TCP Socket Test').onClick(() => {
          this.pageStack.pushPathByName('TcpSocketTestPage', null, false);
        })
        Blank().height(15)
      }.width('100%').height('100%').justifyContent(FlexAlign.Center)
    }.mode(NavigationMode.Auto)
    .hideTitleBar(true)
  }
}