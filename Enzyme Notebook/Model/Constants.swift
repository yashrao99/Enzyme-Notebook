//
//  Constants.swift
//  Enzyme Notebook
//
//  Created by Yash Rao on 3/8/18.
//  Copyright © 2018 com.YashasRao99. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    struct textViewText {
        
        static let protocolTextView = "List out your general protocol.\n You will fill in the details later!\n Example:\n Grow E.coli cultures for 24 hours at 37° C.\n Spin down cells at 3000x rpm for 30 minutes.\n Add 30 mL of Lysis buffer and sonicate at 30% amplitude 3 times.\n Ultracentrifuge at 33,000 rpm and pool supernatant.\n Inject supernatant into FPLC with Ni-NTA column at 2 mL/min.\n Elute with HisB buffer with 500 mm imidazole.\n Analyze elute using gel electrophoresis (SDS-Page)."
        
        static let detailTextView1 = "List out the details of what you did. Example:\n\n I added 25.0g of CaCl2, 40 g NaCL to 950 mL of Nano-pure water.\n I then added 50 mL of 500 mM TRIS pH 7.5 to bring the total volume to 1 mL.\n I checked the pH and added 1 mL of 1M HCL to bring the pH down to 6.5. (TAKE PICTURE OF PH PROBE)"
        
        static let detailTextView2 = "List out any observations/thoughts that you may have had when carrying out your experiment. Example:\n\n The eluent from the column came as two distinct peaks at A280 rather than one single peak (TAKE A PICTURE of chromatogram). This might be attributed to the lack of bound co-factor which stabilizes the homo-dimer of the protein, reuslting in both the monomer and homo-dimer\n\n I then used gel electrophoresis and the resulting band size was 60 and 30 kDa, the monomer and the homo-dimer (Take picture of gel)"
        
        static let genericText = "Please fill this in"
        
        static let titleText = "Please name your experiment"
        
        static let detailText = "Title of protocol task"
        
        static let notificationTxt = "Please set the text for your reminder"
    }
}


extension Date {
    func string(with format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
