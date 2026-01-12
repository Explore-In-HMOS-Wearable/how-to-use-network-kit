import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Builder
export function TcpSocketTestPageBuilder() {
  TcpSocketTestPage();
}

@Entry
@Component
struct TcpSocketTestPage {
  private tcp = socket.constructTCPSocketInstance();
  @State log: string = 'Press connect to start TCP test.\n';
  pathStack: NavPathStack = new NavPathStack();
  private bindAddress = ''; //PLEASE USE AN REAL IP ADDRESS HERE!!

  private appendLog(message: string) {
    this.log += `[${new Date().toLocaleTimeString()}] ${message}\n`;
    console.info(message);
  }

  private setupSocketEvents() {
    this.tcp.on('connect', () => {
      this.appendLog('✅ Connected to server');
      this.sendTestMessage();
    });

    this.tcp.on('message', (value) => {
      const buffer = new Uint8Array(value.message);
      const message = Array.from(buffer).map(byte => String.fromCharCode(byte)).join('');
      this.appendLog(`📥 Received: ${message}`);
    });

    this.tcp.on('error', (err: BusinessError) => {
      this.appendLog(`❌ Socket error: ${JSON.stringify(err)}`);
    });

    this.tcp.on('close', () => {
      this.appendLog('🔒 Socket closed');
    });
  }

  private connectToServer() {
    this.setupSocketEvents();

    const bindAddress: socket.NetAddress = {
      address: this.bindAddress,
      port: 0
    };

    this.tcp.bind(bindAddress, (err: BusinessError) => {
      if (err) {
        this.appendLog(`❌ Bind failed: ${JSON.stringify(err)}`);
        return;
      }

      this.appendLog('🔗 Bound to local port');

      const remoteAddress: socket.NetAddress = {
        address: 'tcpbin.com',
        port: 4242
      };

      const connectOptions: socket.TCPConnectOptions = {
        address: remoteAddress,
        timeout: 6000
      };

      this.appendLog('🌐 Connecting to tcpbin.com:4243 ...');

      this.tcp.connect(connectOptions).then(() => {
        this.appendLog('➡️ Connect initiated');
      }).catch((err: BusinessError) => {
        this.appendLog(`❌ Connect failed: ${JSON.stringify(err)}`);
      });
    });
  }

  private sendTestMessage() {
    const message = 'Hello TCP Server\n';
    const sendOptions: socket.TCPSendOptions = {
      data: message
    };

    this.tcp.send(sendOptions).then(() => {
      this.appendLog(`📤 Sent: ${message}`);
    }).catch((err: BusinessError) => {
      this.appendLog(`❌ Send failed: ${JSON.stringify(err)}`);
    });
  }

  private closeSocket() {
    this.tcp.close().then(() => {
      this.appendLog('🔚 Socket closed manually');
    }).catch((err: BusinessError) => {
      this.appendLog(`❌ Close failed: ${JSON.stringify(err)}`);
    });

    this.tcp.off('connect');
    this.tcp.off('message');
    this.tcp.off('close');
    this.tcp.off('error');
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Button('Connect to TCP Echo Server').onClick(() => this.connectToServer())
          Button('Send Test Message').onClick(() => this.sendTestMessage())
          Button('Close Connection').onClick(() => this.closeSocket())

          Text(this.log)
            .fontSize(14)
            .padding(10)
        }
        .padding(20)
      }.scrollable(ScrollDirection.Vertical)
    }
    .margin({top:15})
    .title('Tcp Socket')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}
