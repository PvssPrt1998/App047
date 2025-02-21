import SwiftUI
import Photos
import ApphudSDK

final class Source: ObservableObject {
    
    var productsApphud: Array<ApphudProduct> = []
    @Published var videoIDs: Array<Video> = []
    private var paywallID = "main"
    @Published var proSubscription = false
    var onAppearRequested = false
    var selectedEffect = ""
    var effectImage: UIImage?
    var localUrl: URL?
    var currentVideoId: String = ""
    let dataManager = DataManager()
    var effectId: Int?
    var preventDouble = false
    var isEffect = true
    var promts: String?
    
    @MainActor func load(completion: @escaping (Bool) -> Void) {
        if let vids = try? dataManager.fetchVideoIds() {
            vids.forEach { video in
                if !video.isEffect, let urlStr = video.url, let url: NSURL = NSURL(string: urlStr), let filename = url.lastPathComponent  {
                    let newPath = "file:///" + documentsPathForFileName(name: "/" + filename)
                    videoIDs.append(Video(id: video.id, isEffect: video.isEffect, url: newPath))
                } else {
                    videoIDs.append(video)
                }
            }
        }
        loadPaywalls { value in
            if self.hasActiveSubscription() {
                self.proSubscription = true
            }
            completion(value)
        }
    }
    
    @MainActor
    func loadPaywalls(completion: @escaping (Bool) -> Void) {
        Apphud.paywallsDidLoadCallback { paywalls, arg in
            if let paywall = paywalls.first(where: {$0.identifier == self.paywallID}) {
                Apphud.paywallShown(paywall)
                let products = paywall.products
                self.productsApphud = products
//                print(self.returnName(product: self.productsApphud[0]))
                completion(products.count >= 2 ? true : false)
                
            }
        }
    }
    
    @MainActor
    func hasActiveSubscription() -> Bool {
        Apphud.hasActiveSubscription()
    }
    
    @MainActor
    func returnPrice(product: ApphudProduct) -> String {
        return product.skProduct?.price.stringValue ?? ""
    }

    @MainActor
    func returnPriceSign(product: ApphudProduct) -> String {
        return product.skProduct?.priceLocale.currencySymbol ?? ""
    }
    
    private func getSubscriptionPrice(for product: ApphudProduct) -> Double {
        if let price = product.skProduct?.price {
            return Double(truncating: price)
        } else {
            return 0
        }
    }
    
    @MainActor
    func returnName(product: ApphudProduct) -> String {
        guard let subscriptionPeriod = product.skProduct?.subscriptionPeriod else { return "" }
        
        switch subscriptionPeriod.unit {
        case .day:
            return "Weekly"
        case .week:
            return "Weekly"
        case .month:
            return "Monthly"
        case .year:
            return "Annual"
        @unknown default:
            return "Unknown"
        }
    }
    
    @MainActor
    func startPurchase(product: ApphudProduct, escaping: @escaping(Bool)->Void) {
        let selectedProduct = product
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            debugPrint(result)
            if let subscription = result.subscription, subscription.isActive() {
                escaping(true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                escaping(true)
            } else {
                if Apphud.hasActiveSubscription() {
                    escaping(true)
                }
            }
        }
    }
    
    @MainActor
    func restorePurchase(escaping: @escaping (Bool) -> Void) {
        print("restore")
        Apphud.restorePurchases { subscriptions, _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            if subscriptions?.first?.isActive() ?? false {
                escaping(true)
            }
            if Apphud.hasActiveSubscription() {
                escaping(true)
            }
        }
    }
    
    func removeVideo(_ id: String) {
        guard let index = videoIDs.firstIndex(where: {$0.id == id}) else { return }
        videoIDs.remove(at: index)
        try? dataManager.removeVideo(id)
    }
    
    var documentsUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func dateToString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"//"yyyy/MM/dd"
        return dateFormatter.string(from: date)
    }
    
    func saveUrl(id: String, url: String) {
        guard let index = videoIDs.firstIndex(where: {$0.id == id}) else { return }
        let item = Video(id: id, isEffect: videoIDs[index].isEffect, url: url, date: dateToString(Date()))
        dataManager.editVideo(id, url: url)
        DispatchQueue.main.async {
            self.videoIDs[index] = item
        }
    }
    
    func save(image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsUrl.appendingPathComponent(fileName)
        if let imageData = image.jpegData(compressionQuality: 0.7) {
           try? imageData.write(to: fileURL, options: .atomic)
            return fileURL.path // ----> Save fileName
        }
        print("Error saving image")
        return nil
    }
    
    func generateEffect(
        userId: String,
        appId: String,
        completion: @escaping (String) -> Void,
        errorHandler: @escaping () -> Void
    ) {
        guard let url = URL(string: "https://vewapnew.online/api/generate"), let effectId = self.effectId else {
            print("Invalid URL for generateEffect.")
            errorHandler()
            return
        }
        print(effectId)
        let templateId = "\(effectId)"
        let imageFilePath = save(image: effectImage!)
        print(imageFilePath)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let bearerToken = "rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w"
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"templateId\"\r\n\r\n")
        body.append("\(templateId)\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"userId\"\r\n\r\n")
        body.append("\(userId)\r\n")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"appId\"\r\n\r\n")
        body.append("\(appId)\r\n")
        
        if let imageFilePath = imageFilePath {
            do {
                let fileName = (imageFilePath as NSString).lastPathComponent
                print(fileName)
                let imageData = try Data(contentsOf: URL(fileURLWithPath: imageFilePath)) //guard let imageData = effectImage?.jpegData(compressionQuality: 0.5) else { return }//
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"image\"; filename=\"\(fileName)\"\r\n")
                body.append("Content-Type: image/jpeg\r\n\r\n")
                body.append(imageData)
                body.append("\r\n")
            } catch {
                errorHandler()
                return
            }
        } else {
            errorHandler()
            print("No image file provided.")
        }
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request body:\n\(bodyString)")
        }
        
        if let bodySize = request.httpBody?.count {
            print("HTTP Body size: \(bodySize) bytes")
        }
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            print(response)
            guard let responseData = data else {
                errorHandler()
              print("nil Data received from the server")
              return
            }
            if let rawResponse = String(data: responseData, encoding: .utf8) {
                print("Raw Response to generateEffect:\n\(rawResponse)")
            } else {
                print("Unable to parse raw response as string.")
            }
            
            do {
                let response = try JSONDecoder().decode(ImageGenerationResult.self, from: responseData)
                print(response.data?.generationID)
                if let id = response.data?.generationID  {
                    if id.contains("went") {
                        errorHandler()
                    } else {
                        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        let destinationURL = documentsURL.appendingPathComponent(id + ".mp4")
                        self.localUrl = destinationURL
                        self.save(id, isEffect: true)
                        completion(id)
                    }
                } else {
                    errorHandler()
                }
            } catch let error {
              //print(error.localizedDescription)
                errorHandler()
                print("error: ", error)
            }
//
        }
        task.resume()
    }
    
    func save(_ id: String, isEffect: Bool) {
        DispatchQueue.main.async {
            self.videoIDs.append(Video(id: id, isEffect: isEffect, url: nil))
            self.dataManager.saveVideoId(id, isEffect: isEffect)
        }
       
    }
    
    private func albumExists(albumName: String) -> Bool {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collection.firstObject != nil
    }

    func saveVideo(videoURL: URL, to album: PHAssetCollection, errorHandler: @escaping () -> Void) {
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album)
            let enumeration: NSArray = [assetChangeRequest!.placeholderForCreatedAsset!]
            albumChangeRequest?.addAssets(enumeration)
        }, completionHandler: { success, error in
            if success {
                print("Successfully saved video to album")
            } else {
                print("Error saving video to album: \(error?.localizedDescription ?? "")")
                errorHandler()
            }
        })
    }
    
    func saveVideoToAlbum(videoURL: URL, albumName: String, errorHandler: @escaping ()-> Void, completion: @escaping () -> Void) {
        if albumExists(albumName: albumName) {
            let fetchOptions = PHFetchOptions()
            fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
            let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
            if let album = collection.firstObject {
                saveVideo(videoURL: videoURL, to: album, errorHandler: {errorHandler()})
            } else {
                errorHandler()
            }
        } else {
            var albumPlaceholder: PHObjectPlaceholder?
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
                albumPlaceholder = createAlbumRequest.placeholderForCreatedAssetCollection
            }, completionHandler: { success, error in
                if success {
                    guard let albumPlaceholder = albumPlaceholder else { return }
                    let collectionFetchResult = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumPlaceholder.localIdentifier], options: nil)
                    guard let album = collectionFetchResult.firstObject else { return }
                    self.saveVideo(videoURL: videoURL, to: album, errorHandler: {errorHandler()})
                } else {
                    print("Error creating album: \(error?.localizedDescription ?? "")")
                    errorHandler()
                }
            })
        }
    }
    
    func downloadVideo() {
        guard let url =  URL(string: API.url + "/file/" + "1f60444c-8237-4406-9764-d14e3a968ea2") else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue(API.key, forHTTPHeaderField: "access-token")
        request.httpMethod = "GET"
            let task = session.dataTask(with: request) { (data, response, error) in
                guard error == nil else {
                    print("ERROR DOWNLOAD")
                    return
                }
                print("123")
                let downloadTask = session.downloadTask(with: url)
                downloadTask.resume()
            }
            task.resume()
        }
    
    func documentsPathForFileName(name: String) -> String {
            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            return documentsPath.appending(name)
    }
    
    func textToVideo1(text: String, errorHandler: @escaping () -> Void, completion: @escaping (String) -> ()) {
        guard let url = URL(string: "https://teremappol.shop/video") else {
            print("Invalid URL for textToVideo.")
            errorHandler()
            return
        }
        let parameters: [String: Any] = [
            "prompt": text,
            "user_id" : API.key, //"c82d075d-b216-4e24-acbb-5f70db5dd864",
            "app_bundle": "com.iri.m1n1m4x41vg"
        ]
        var body = Data()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue("c82d075d-b216-4e24-acbb-5f70db5dd864", forHTTPHeaderField: "access-token")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"prompt\"\r\n\r\n")
        body.append("\(text)\r\n")
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n")
        body.append("\(API.key)\r\n")
        body.append("Content-Disposition: form-data; name=\"app_bundle\"\r\n\r\n")
        body.append("com.iri.m1n1m4x41vg\r\n")
        
        body.append("--\(boundary)--\r\n")
        request.httpBody = body
        let session = URLSession.shared
//        do {
//            let json = try JSONSerialization.data(withJSONObject: parameters, options: [.fragmentsAllowed])
//            let jsonTest = try JSONSerialization.jsonObject(with: json)
//            print(jsonTest)
//          request.httpBody = json
//        } catch let error {
//          print(error.localizedDescription)
//            print(error)
//          return
//        }
        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                print(error)
                errorHandler()
                return
            }
            guard let responseData = data else {
                errorHandler()
              print("nil Data received from the server")
              return
            }
            if let rawResponse = String(data: responseData, encoding: .utf8) {
                print("Raw Response to generate with text:\n\(rawResponse)")
            } else {
                print("Unable to parse raw response as string.")
            }
          // ensure there is valid response code returned from this HTTP response
            print("text2Video \(response)")
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
          else {
            print("Invalid Response received from the server")
            errorHandler()
            return
          }
          // ensure there is data returned
          
          
          do {
              let response = try JSONDecoder().decode(ResponseID.self, from: responseData)
              print("data")
              print(response.id)
              if response.isInvalid {
                  errorHandler()
              } else {
                  self.save(response.id, isEffect: false)
                  completion(response.id)
              }
          } catch let error {
            //print(error.localizedDescription)
              errorHandler()
              print("error: ", error)
          }
        }
        task.resume()
    }
    
    func textToVideo(text: String, errorHandler: @escaping () -> Void, completion: @escaping (String) -> ()) {
        let parameters: [String: Any] = [
            "prompt": text,
            "user_id" : API.key, //"c82d075d-b216-4e24-acbb-5f70db5dd864",
            "app_bundle": "com.iri.m1n1m4x41vg"
        ]
        print(text)
        guard let url =  URL(string: API.url) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(API.key, forHTTPHeaderField: "access-token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type") // change as per server requirements
        
        do {
            let json = try JSONSerialization.data(withJSONObject: parameters, options: [.fragmentsAllowed])
            let jsonTest = try JSONSerialization.jsonObject(with: json)
            print(jsonTest)
          request.httpBody = json
        } catch let error {
          print(error.localizedDescription)
            print(error)
          return
        }
        
        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                print(error)
                errorHandler()
                return
            }
            guard let responseData = data else {
                errorHandler()
              print("nil Data received from the server")
              return
            }
            if let rawResponse = String(data: responseData, encoding: .utf8) {
                print("Raw Response to generate with text:\n\(rawResponse)")
            } else {
                print("Unable to parse raw response as string.")
            }
          // ensure there is valid response code returned from this HTTP response
            print("text2Video \(response)")
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
          else {
            print("Invalid Response received from the server")
            errorHandler()
            return
          }
          // ensure there is data returned
          
          
          do {
              let response = try JSONDecoder().decode(ResponseID.self, from: responseData)
              print("data")
              print(response.id)
              if response.isInvalid {
                  errorHandler()
              } else {
                  self.save(response.id, isEffect: false)
                  completion(response.id)
              }
          } catch let error {
            //print(error.localizedDescription)
              errorHandler()
              print("error: ", error)
          }
        }
        task.resume()
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }
    
    func getEffectURLById(id: String, completion: @escaping (URL?, Bool) -> Void, errorHandler: @escaping () -> Void) {
        var request = URLRequest(url: URL(string: "https://vewapnew.online/api/generationStatus?generationId=" + id)!,timeoutInterval: Double.infinity)

        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer rE176kzVVqjtWeGToppo4lRcbz3HRLoBrZREEvgQ8fKdWuxySCw6tv52BdLKBkZTOHWda5ISwLUVTyRoZEF0A33Xpk63lF9wTCtDxOs8XK3YArAiqIXVb7ZS4IK61TYPQMu5WqzFWwXtZc1jo8w", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           guard let responseData = data else {
              
              print(String(describing: error))
              return
           }
            do {
                let response = try JSONDecoder().decode(ImageGenerationResult.self, from: responseData)
                print(response)
                if let status = response.data?.status, !status.contains("went") {
                    if status != "finished" {
                        completion(nil, false)
                    } else if let urlStr = response.data?.resultURL, let url = URL(string: urlStr) {
                        completion(url, true)
                    } else {
                        errorHandler()
                    }
                } else {
                    errorHandler()
                }
            } catch let error {
              //print(error.localizedDescription)
                errorHandler()
                print("error: ", error)
            }
        }

        task.resume()
    }
    
    func videoById(id: String, completion: @escaping (URL) -> (), errorHandler: @escaping () -> Void) {
        guard let url =  URL(string: "https://teremappol.shop/video" + "/file/" + id) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue("*/*", forHTTPHeaderField: "accept")
        request.addValue(API.key, forHTTPHeaderField: "access-token")
        request.httpMethod = "GET"
        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                print(error)
                errorHandler()
                return
            }
          // ensure there is valid response code returned from this HTTP response
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
          else {
            print("Invalid Response received from the server")
            errorHandler()
            return
          }
          // ensure there is data returned
          guard let responseData = data else {
              errorHandler()
            print("nil Data received from the server")
            return
          }
            print("RESPONSE DATA")
            print(responseData)
            
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let destinationURL = documentsURL.appendingPathComponent(id + ".mp4")
            do {
                try responseData.write(to: destinationURL)
                self.localUrl = destinationURL
                DispatchQueue.main.async {
                    //self.videoIDs[index].url = response
                }
                completion(destinationURL)
                //self.saveVideoToAlbum(videoURL: destinationURL, albumName: "MyAlbum")
                print(destinationURL)
            } catch {
                print("Error saving file:", error)
                errorHandler()
            }
        }
        task.resume()
    }
    
    func isGenerationFinished(id: String, completion: @escaping (Bool) -> (), errorHandler: @escaping () -> Void) {
        print("isGenerationFinished")
        guard let url =  URL(string: "https://teremappol.shop/video" + "/" + id) else { return }
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(API.key, forHTTPHeaderField: "access-token")
        request.httpMethod = "GET"
        // create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Post Request Error: \(error.localizedDescription)")
                print(error)
                errorHandler()
                return
            }
          // ensure there is valid response code returned from this HTTP response
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
          else {
            print("Invalid Response received from the server")
            errorHandler()
            return
          }
          // ensure there is data returned
          guard let responseData = data else {
              errorHandler()
            print("nil Data received from the server")
            return
          }
          
          do {
              let response = try JSONDecoder().decode(ResponseID.self, from: responseData)
              print(response)
              if response.isInvalid {
                  errorHandler()
              } else {
                  completion(response.isFinished)
              }
              print(response.id)
          } catch let error {
            //print(error.localizedDescription)
              errorHandler()
              print("error: ", error)
          }
        }
        task.resume()
    }
    
    var effects = [
        Effect(title: "Dissolve it", id: 13, url: "https://vewapnew.online/storage/preview/zQWrJEFKvsfHFsClgR5yzW3yHCVXLlmQWM6rGdz7.mp4?t=1738906171"),
        Effect(title: "Decapitate it", id: 2, url: "https://vewapnew.online/storage/preview/QolvHeHOCxB3naJbijWEDUJmNPrifsUlVqNvGLxv.mp4?t=1738906171"),
        Effect(title: "Melt it", id: 5, url: "https://vewapnew.online/storage/preview/ssPRdA5xjg8EajVxgRgC7bZxTq65jqsYs4bMcTON.mp4?t=1738906171"),
        Effect(title: "Inflate it", id: 4, url: "https://vewapnew.online/storage/preview/iDNDGK5y9zMMatybYoK9tCZnywS8MU8IWWJFaV8Z.mp4?t=1738906171"),
        Effect(title: "Eye-pop it", id: 3, url: "https://vewapnew.online/storage/preview/vWy7H3nQovCQPfVMsN00SaZzDJjZDNqGUJgyiqTA.mp4?t=1738906171"),
        Effect(title: "Levitate it", id: 1, url: "https://vewapnew.online/storage/preview/9JX57sakrQniJBdcFfyBWDXmDfIQj3UfmlDJkpax.mp4?t=1738906171")
    ]
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

class API {
    static var key = "c82d075d-b216-4e24-acbb-5f70db5dd864"
    static var url = "https://teremappol.shop/video/text"
    static var imageServerUrl = "https://huggerapp.shop/api/upload"
}
