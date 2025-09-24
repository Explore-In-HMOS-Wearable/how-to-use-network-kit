import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function WebSocketTestPageBuilder() {
  WebSocketTestPage();
}

let defaultIpAddress = 'ws://';
let ws = webSocket.createWebSocket();

@Entry
@Component
struct WebSocketTestPage {
  @State log: string = 'Press Connect to start WebSocket testing.\n';
  pathStack: NavPathStack = new NavPathStack();

  private appendLog(msg: string) {
    this.log += `[${new Date().toLocaleTimeString()}] ${msg}\n`;
    console.info(msg);
  }

  private connectWebSocket() {
    if (ws !== null) {
      this.appendLog('Already connected or connecting.');
      return;
    }

    ws = webSocket.createWebSocket();

    ws.on('open', () => {
      this.appendLog('WebSocket connected ✅');
      ws?.send('Hello WebSocket 👋');
    });

    ws.on('message', (err: BusinessError, value: string | ArrayBuffer) => {
      if (typeof value === 'string') {
        this.appendLog('Received string message: ' + value);
      } else {
        this.appendLog('Received binary message: ' + value.toString());
      }
    });

    ws.on('error', (err: Error) => {
      this.appendLog('WebSocket error ❌: ' + JSON.stringify(err));
    });

    ws.on('close', () => {
      this.appendLog('WebSocket closed 🔚');
    });

    const url = 'wss://echo.websocket.org';
    this.appendLog('Connecting to: ' + url);

    try {
      ws.connect(url);
    } catch (e) {
      this.appendLog('Connection exception: ' + JSON.stringify(e));
    }
  }

  private sendMessage() {
    if (!ws) {
      this.appendLog('WebSocket not connected.');
      return;
    }

    try {
      const message = 'Ping 🛰️ at ' + new Date().toISOString();
      ws.send(message);
      this.appendLog('Sent: ' + message);
    } catch (e) {
      this.appendLog('Send failed: ' + JSON.stringify(e));
    }
  }

  private closeConnection() {
    if (!ws) {
      this.appendLog('WebSocket already closed.');
      return;
    }

    try {
      ws.close();
      this.appendLog('Close initiated.');
    } catch (e) {
      this.appendLog('Close failed: ' + JSON.stringify(e));
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Button('Connect WebSocket')
            .onClick(() => this.connectWebSocket())

          Button('Send Message')
            .onClick(() => this.sendMessage())

          Button('Close WebSocket')
            .onClick(() => this.closeConnection())

          Scroll() {
            Text(this.log)
              .fontSize(14)
              .padding(10)
          }.height('60%')
        }
        .padding(20)
      }.scrollable(ScrollDirection.Vertical)
    }
    .margin({top:15})
    .title('Web Socket')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}
