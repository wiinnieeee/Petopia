//
//  AboutAppViewController.swift
//  petopia
//
//  Created by Winnie Ooi on 31/5/2023.
//

import UIKit

class AboutAppViewController: UIViewController {

    @IBOutlet weak var acknowledgementsView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        acknowledgementsView.text = "Petopia is a mobile application that is designed to focus on pet adoption. The mobile application is designed for pet lovers and people who are interested in adopting pets."
        
        acknowledgementsView.text += "\n\nThe app includes the use of the following Third Party Libraries:"
        
        acknowledgementsView.text += "\n\n1. Firebase Apache License\n\nCopyright [2023] [Winnie Ooi Yun Ting]\nLicensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License. You may obtain a copy of the License at\n\nhttp://www.apache.org/licenses/LICENSE-2.0\n\nUnless required by applicable law or agreed to in writing, software distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License."
        
        acknowledgementsView.text += "\n\n2. Message Kit\n\nMIT License\n\nCopyright (c) 2017-2022 MessageKit\n\nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:\n\nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.\n\nTHE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE."
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
