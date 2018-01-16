import UIKit

import QRCode
import QRCodeReader
import Tafelsalz

class ViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var secretTextField: UITextField!
	@IBOutlet weak var qrCodeView: UIImageView!
	@IBOutlet weak var continueButton: UIButton!

	private var qrCodeReader: QRCodeReader? = nil
	private var keyExchange: KeyExchange!

	func showError(title: String, message: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default))
		self.present(alert, animated: true)
	}

	// MARK: UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.

		secretTextField.delegate = self
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	// MARK: UITextFieldDelegate

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder() // Hide keyboard
		return true
	}

	func textFieldDidEndEditing(_ textField: UITextField) {
		let hasText = !(textField.text == nil || textField.text!.isEmpty)
		navigationItem.leftBarButtonItem?.isEnabled = !hasText
		navigationItem.rightBarButtonItem?.isEnabled = hasText
	}

	// MARK: Actions

	@IBAction func exportSecret(_ sender: UIBarButtonItem) {
		keyExchange = KeyExchange(side: .server)

		// Scan public key of client
		qrCodeReader = QRCodeReader()
		do {
			try qrCodeReader!.startScanning() {
				scannedQrCode in

				guard let scannedQrCode = scannedQrCode else {
					return
				}

				guard var clientPkBytes = Data(base64Encoded: scannedQrCode) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import client key", message: "Client key is not Base64 encoded.")
					}
					return
				}

				guard let clientPk = KeyExchange.PublicKey(bytes: &clientPkBytes) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import client key", message: "Client key has invalid size.")
					}
					return
				}

				guard let sessionKey = self.keyExchange.sessionKey(for: clientPk) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot create session key", message: "Client key is not acceptible.")
					}
					return
				}

				// Encrypt secret with session key
				let secretBox = SecretBox(secretKey: SecretBox.SecretKey(sessionKey))
				let ciphertext = secretBox.encrypt(data: Data(self.secretTextField.text!.utf8))

				var dataToExport = Data()
				dataToExport.append(self.keyExchange.publicKey.copyBytes())
				dataToExport.append(ciphertext.bytes)

				DispatchQueue.main.async {
					self.qrCodeView.image = QRCode(dataToExport.base64EncodedData()).image
				}

				self.qrCodeReader = nil
			}
		} catch {
			qrCodeReader = nil
			showError(title: "Cannot import key", message: error.localizedDescription)
		}

	}

	@IBAction func importSecret(_ sender: UIBarButtonItem) {

		keyExchange = KeyExchange(side: .client)

		let pkQr = QRCode(keyExchange.publicKey.copyBytes().base64EncodedData())
		qrCodeView.image = pkQr.image

		continueButton.isEnabled = true
	}

	@IBAction func continueImportingSecret() {
		continueButton.isEnabled = false

		// Scan public key of server
		qrCodeReader = QRCodeReader()
		do {
			try qrCodeReader!.startScanning() {
				scannedQrCode in

				guard let scannedQrCode = scannedQrCode else {
					return
				}

				guard let dataToImport = Data(base64Encoded: scannedQrCode) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import secret", message: "Data not Base64 encoded.")
					}
					return
				}

				var serverPkBytes = dataToImport[0..<Int(KeyExchange.PublicKey.SizeInBytes)]
				let cipherTextBytes = Data(dataToImport[Int(KeyExchange.PublicKey.SizeInBytes)...])

				guard let serverPk = KeyExchange.PublicKey(bytes: &serverPkBytes) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import server key", message: "Server key has invalid size.")
					}
					return
				}

				guard let sessionKey = self.keyExchange.sessionKey(for: serverPk) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot create session key", message: "Server key is not acceptible.")
					}
					return
				}

				// Decrypt secret with session key
				let secretBox = SecretBox(secretKey: SecretBox.SecretKey(sessionKey))

				guard let ciphertext = SecretBox.AuthenticatedCiphertext(bytes: cipherTextBytes) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import secret", message: "Invalid payload size.")
					}
					return
				}

				guard let plaintext = secretBox.decrypt(data: ciphertext) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import secret", message: "Failed to decrypt payload.")
					}
					return
				}

				guard let secret = String(bytes: plaintext, encoding: .utf8) else {
					DispatchQueue.main.async {
						self.showError(title: "Cannot import secret", message: "Decrypted payload is not UTF-8 encoded.")
					}
					return
				}

				DispatchQueue.main.async {
					self.secretTextField.text = secret
				}

				self.qrCodeReader = nil
			}
		} catch {
			qrCodeReader = nil
			showError(title: "Cannot import key", message: error.localizedDescription)
		}

	}

	@IBAction func reset() {
		secretTextField.text = nil
		navigationItem.leftBarButtonItem?.isEnabled = false
		navigationItem.rightBarButtonItem?.isEnabled = true
		qrCodeView.image = nil
		continueButton.isEnabled = false
	}
}
