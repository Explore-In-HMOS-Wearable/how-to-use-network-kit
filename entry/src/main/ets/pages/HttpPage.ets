import http from '@ohos.net.http';

@Builder
export function HttpPageBuilder() {
  HttpPage();
}

@Entry
@Component
struct HttpPage {
  private streamByteUrl = '' //Give your stream byte URL Here
  pathStack: NavPathStack = new NavPathStack();
  @State requestLog: string = 'Press the button to start HTTP test.\n';

  private appendLog(message: string) {
    this.requestLog += `${message}\n`;
    console.info(message);
  }

  private testHttpRequest() {
    const httpRequest = http.createHttp();

    // Register headers receive observer
    httpRequest.on('headersReceive', (header) => {
      this.appendLog(`✅Headers received: ${JSON.stringify(header)}`);
    });

    httpRequest.on('dataSendProgress', (progress) => {
      this.appendLog(`✅Upload Progress: ${progress.sendSize}/${progress.totalSize}`);
    });

    // Send HTTP GET Request
    httpRequest.request(
      `https:// + ${$r('app.string.url')}`,
      {
        method: http.RequestMethod.GET,
        header: {
          'Content-Type': 'application/json'
        },
        readTimeout: 60000, // 60s
        connectTimeout: 10000
      },
      (err, data) => {
        if (err) {
          this.appendLog(`❌Request error: ${JSON.stringify(err)}` );
        } else {
          this.appendLog(`❌Status Code: ${ data.responseCode}`);
          this.appendLog(`✅Response Body: ${data.result}`);
        }

        httpRequest.destroy(); // Clean up
        this.appendLog('✅Request destroyed.\n');
      }
    );
  }

  private testStreamingRequest() {
    const httpRequest = http.createHttp();

    httpRequest.on('headersReceive', (header) => {
      this.appendLog(`✅[Stream] Headers: ${JSON.stringify(header)}`);
    });

    httpRequest.on('dataReceive', (chunk) => {
      this.appendLog(`✅[Stream] Data chunk: ${chunk}` );
    });

    httpRequest.on('dataReceiveProgress', (progress) => {
      this.appendLog(`✅[Stream] Download Progress: ${progress.receiveSize}/${progress.totalSize}`);
    });

    httpRequest.on('dataEnd', () => {
      this.appendLog('✅[Stream] All data received.');
      httpRequest.destroy();
    });

    // Use bytes endpoint for large content
    httpRequest.requestInStream(
      this.streamByteUrl,
      {
        method: http.RequestMethod.GET,
        header: {
          'Accept': 'application/octet-stream'
        }
      },
      (err) => {
        if (err) {
          this.appendLog(`❌[Stream] Error: ${JSON.stringify(err)}`);
          httpRequest.destroy();
        }
      }
    );
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 16 }) {
          Button('Test Standard HTTP Request')
            .onClick(() => this.testHttpRequest())

          Button('Test Streaming HTTP Request')
            .onClick(() => this.testStreamingRequest())

          Scroll() {
            Text(this.requestLog)
              .fontSize(14)
              .padding(10)
          }.height('60%')
        }
        .padding(20)
        .alignItems(HorizontalAlign.Center)
      }.scrollable(ScrollDirection.Vertical)
    }
    .margin({ top: 15 })
    .title('HttpPage')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack;
    })
  }
}