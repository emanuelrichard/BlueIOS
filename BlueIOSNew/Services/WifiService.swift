//
//  WifiService.swift
//  BlueIOSNew
//
//  Created by Opportunity on 10/04/23.
//

import Foundation

class WiFiService: NSObject {

    static let it = WiFiService()

    var state: Connection.State = Connection.State.DISCONNECTED

    var inputStream: InputStream!
    var outputStream: OutputStream!
    let maxReadLength = 4096

    private var keepAliveTimer: Timer!
    private var keepAliveCounter = 0

    var connectedBTid: String? = nil
    private var wifiTubaddress = ""
    private let wifiPort = 5000
    func setNetwork(BTid: String, ip: String) -> WiFiService {
        connectedBTid = BTid
        wifiTubaddress = ip
        return self
    }

    var connDelegate: ConnectingProtocol?
    var commDelegate: CommunicationProtocol?
    func delegates(conn: ConnectingProtocol, comm: CommunicationProtocol?) -> WiFiService {
        connDelegate = conn
        if(comm != nil) {
            commDelegate = comm
        }
        return self
    }
    func ok() { /* Use with delegates() to avoid warnings */}

    func connect() {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?

        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,
                                         wifiTubaddress as CFString,
                                         UInt32(wifiPort),
                                         &readStream,
                                         &writeStream)

        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()

        inputStream.delegate = self
//        outputStream.delegate = self

        inputStream.schedule(in: .current, forMode: .common)
        outputStream.schedule(in: .current, forMode: .common)

        inputStream.open()
        outputStream.open()

        state = Connection.State.CONNECTING
        connDelegate?.didStartConnectingTub()

        keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: false, block: { t in
            self.state = Connection.State.FAILED
            self.connDelegate?.didFail()
            self.disconnect()
        })
    }

    func disconnect() {
        inputStream.delegate = nil
        outputStream.delegate = nil

        inputStream.remove(from: .current, forMode: .common)
        outputStream.remove(from: .current, forMode: .common)

        inputStream.close()
        outputStream.close()

        keepAliveTimer?.invalidate()
        keepAliveCounter = 0

        Settings.last_BTid = Settings.BTid
        connectedBTid = nil
        Settings.BTid = ""

        state = Connection.State.DISCONNECTED
        connDelegate?.didDisconnectTub()

        //print("Dead ! - \(Date())")
    }

    func sendCommand(command: String) {
            let data = command.data(using: .utf8)!

        data.withUnsafeBytes {
                guard let pointer = $0.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    return
                }

                outputStream.write(pointer, maxLength: data.count)
            }
        }

    }

extension WiFiService: StreamDelegate {

    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        switch eventCode {
        case .hasBytesAvailable:
            readAvailableBytes(stream: aStream as! InputStream)
        case .openCompleted:
            keepAliveTimer.invalidate()

            print("Born ! - \(Date())")
            Settings.BTid = connectedBTid ?? ""
            Settings.last_BTid = Settings.BTid
            state = Connection.State.CONNECTED
            connDelegate?.didConnectTub()

            keepAliveTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { t in
                self.keepAliveCounter += 1
                Utils.sendCommand(cmd: TubCommands.GET_LEVEL, value: nil, word: nil)

                if(self.keepAliveCounter > 3) {
                    //print("Will die ! - \(Date())")
                    self.disconnect()
                    t.invalidate()
                }
            })

        default:
            self.disconnect()
            state = Connection.State.DISCONNECTED
        }
    }

    private func readAvailableBytes(stream: InputStream) {
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxReadLength)

        while stream.hasBytesAvailable {
            let numberOfBytesRead = inputStream.read(buffer, maxLength: maxReadLength)

            if numberOfBytesRead < 0, let _ = stream.streamError {
              //print(error)
              break
            }

            if let feedbacks = processedMessageString(buffer: buffer, length: numberOfBytesRead) {
                let feedback_arr = feedbacks.split(separator: "\n")
                for feedback in feedback_arr {
                    let fbk = String(feedback)
                    if(!fbk.isEmpty && commDelegate != nil){
                        if let parsed_fbk = Utils.getParsedFeedback(feedback: fbk) {
                            //print("\(parsed_fbk[0]): \(parsed_fbk[1])")
                            self.keepAliveCounter = 0
                            let about = String(parsed_fbk[0])
                            if let value = Int(String(parsed_fbk[1])) {
                                Settings.updateIntSettings(about: about, value: value)
                                commDelegate!.didReceiveFeedback(about: about, value: value)
                            } else {
                                let text = String(parsed_fbk[1])
                                Settings.updateStrSettings(about: about, text: text)
                                commDelegate!.didReceiveFeedback(about: about, text: text)
                            }
                        } //else {
//                            print(" *** Poh Sérgio, tá vacilando no Chave-Valor !! :/")
//                        }
                    }
                }
            } else {
                print("No feedback got !!!!")
                //disconnect()
            }
        }
    }

    private func processedMessageString(buffer: UnsafeMutablePointer<UInt8>, length: Int) -> String? {
        guard
            let message = String(
              bytesNoCopy: buffer,
              length: length,
              encoding: .utf8,
              freeWhenDone: true)
        else {
              return nil
        }

        return message
    }

}
