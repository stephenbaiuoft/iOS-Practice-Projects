//
//  ViewController.swift
//  SleepingInTheLibrary
//
//  Created by Jarrod Parkes on 11/3/15.
//  Copyright © 2015 Udacity. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController
/*
 let someParameters = [
 "course":"networking",
 "nanodegree":"ios",
 "quiz":"escaping parameters"
 ]
  print(escapeParameters(parameters: someParameters as [String : AnyObject]) )
 */

class ViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
    @IBOutlet weak var grabImageButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func grabNewImage(_ sender: AnyObject) {
        setUIEnabled(false)
        getImageFromFlickr()
    }
    
    override func viewDidLoad() {

    }

    
    // Escapes and builds a url string for Flickr
    func escapeParameters( parameters:[String:AnyObject])->String{
        if parameters.isEmpty{
            return ""
        }
        var keyValuePairs = [String]()
        
        for pair in parameters{
            let stringValue =  pair.value as! String
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            keyValuePairs.append(pair.key + "=" + escapedValue!)
            
        }
        
        return "?" + keyValuePairs.joined(separator: "&")
        
    }
    
    // MARK: Configure UI
    
    private func setUIEnabled(_ enabled: Bool) {
        photoTitleLabel.isEnabled = enabled
        grabImageButton.isEnabled = enabled
        
        if enabled {
            grabImageButton.alpha = 1.0
        } else {
            grabImageButton.alpha = 0.5
        }
    }
    
    // MARK: Make Network Request
/*
     
      https://api.flickr.com/services/rest/?method=flickr.galleries.getPhotos&api_key=5142218342723e79cdf2adb6b8b42faf&gallery_id=36547953456&extras=url_m&format=json&nojsoncallback=1&auth_token=72157684160952012-6c63a62881b04575&api_sig=d2161d4f56ef830de02616d7b6f7a3ea
*/
    
    func buildUrlString() -> String{
        var parameters = [String:AnyObject]()
        parameters[Constants.FlickrParameterKeys.APIKey] = Constants.FlickrParameterValues.APIKey as AnyObject
        parameters[Constants.FlickrParameterKeys.Extras] = Constants.FlickrParameterValues.MediumURL as AnyObject
        parameters[Constants.FlickrParameterKeys.GalleryID] = Constants.FlickrParameterValues.GalleryID as AnyObject
        parameters[Constants.FlickrParameterKeys.Method] = Constants.FlickrParameterValues.GalleryPhotosMethod as AnyObject
        parameters[Constants.FlickrParameterKeys.NoJSONCallback] = Constants.FlickrParameterValues.DisableJSONCallback as AnyObject
        parameters[Constants.FlickrParameterKeys.Format] = Constants.FlickrParameterValues.ResponseFormat as AnyObject
        
        let urlString = Constants.Flickr.APIBaseURL + escapeParameters(parameters: parameters)
        return urlString
    }
    
    private func getImageFromFlickr() {
        
        // TODO: Write the network code here!
        let urlString = buildUrlString()
        
        let url = URL.init(string: urlString)

        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String){
                print(error)
                print("URL at time of error:", url!)
                performUIUpdatesOnMain {
                    self.setUIEnabled(true)
                }
                
            }
            
            if(error == nil){
                //let parsedResult: Any
                let parsedResult: [String:Any]
                do{
                    parsedResult = try (JSONSerialization.jsonObject(with: data!, options: .allowFragments ) as! [String: Any])
                    
                    if let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:Any] {
                        if let photoArray = photosDictionary[Constants.FlickrResponseKeys.Photo] as? [[String:Any]]{
                            
                            let randomPhotoIndex = Int(arc4random_uniform(UInt32(photoArray.count)))
                            let photoDictionary = photoArray[randomPhotoIndex] as [String:AnyObject]
                            
                            if let imageUrlString = photoDictionary[Constants.FlickrResponseKeys.MediumURL] as? String,
                                let photoTitle = photoDictionary[Constants.FlickrResponseKeys.Title] as? String {
                                let imageUrl = URL.init(string: imageUrlString)
                                if let imageData = try? Data.init(contentsOf: imageUrl!, options: []){
                                performUIUpdatesOnMain {
                                    self.photoImageView.image = UIImage.init(data: imageData)
                                    self.photoTitleLabel.text = photoTitle
                                    self.setUIEnabled(true)
                                    }
                                    
                                }
                                
                            }
                            
                        }
                    }else{
                        print("unable to access photoDictionary")
                    }
                    
                } catch{
                    print("could not parse data as Json:" , data!)
                    return
                }
                
                print("Printing parsedResult\n",parsedResult)
            }
        }
        task.resume()
        
    }
    
}

    
