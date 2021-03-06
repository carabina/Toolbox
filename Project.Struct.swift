import XCEProjectGenerator

//===

let params =
(
    repoName: "Toolbox",
    deploymentTarget: "9.0",
    companyIdentifier: "io.XCEssentials",
    companyPrefix: "XCE"
)

let bundleId =
(
    fwk: "\(params.companyIdentifier).\(params.repoName)",
    tst: "\(params.companyIdentifier).\(params.repoName).Tst"
)

//===

let specFormat = Spec.Format.v2_1_0

let project = Project("Main") { project in
    
    project.configurations.all.override(
        
        "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
        
        "SWIFT_VERSION" <<< "3.1",
        "VERSIONING_SYSTEM" <<< "apple-generic",
        
        "CURRENT_PROJECT_VERSION" <<< "0", // just a default non-empty value
        
        "CODE_SIGN_IDENTITY[sdk=iphoneos*]" <<< "" // no need to code sign fwk
    )
    
    project.configurations.debug.override(
        
        "SWIFT_OPTIMIZATION_LEVEL" <<< "-Onone"
    )
    
    //---
    
    project.target("Fwk", .iOS, .framework) { fwk in
        
        fwk.include("Sources")
        
        //---
        
        fwk.configurations.all.override(
            
            "PRODUCT_NAME" <<< "\(params.companyPrefix)\(params.repoName)",
            
            "IPHONEOS_DEPLOYMENT_TARGET" <<< params.deploymentTarget, // bug wokraround
        
            "PRODUCT_BUNDLE_IDENTIFIER" <<< bundleId.fwk,
            "INFOPLIST_FILE" <<< "Info/Fwk.plist",

            "ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES" <<< "$(inherited)",
            
            //--- iOS related:
            
            "SDKROOT" <<< "iphoneos",
            "TARGETED_DEVICE_FAMILY" <<< DeviceFamily.iOS.universal,
            
            //--- Framework related:
            
            "DEFINES_MODULE" <<< "NO",
            "SKIP_INSTALL" <<< "YES"
        )
        
        fwk.configurations.debug.override(
            
            "MTL_ENABLE_DEBUG_INFO" <<< true
        )
    }
}
