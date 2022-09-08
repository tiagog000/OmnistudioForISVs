global without sharing class OmniPostInstallClass implements InstallHandler {
  global void onInstall(InstallContext context) {
    
    //runs everytime
	runFuturePostInstallScript();    
    /*if(context.previousVersion() == null) {
    }
    else
      if(context.previousVersion().compareTo(new Version(1,0)) == 0) {
     
      }
    if(context.isUpgrade()) {
    
      }
    if(context.isPush()) {

      }*/
    }
	@future
    private static void runFuturePostInstallScript(){
        Map<String, Object> Params = new Map<String, Object>();
        Params.put('StaticResourceName','OmniUICards');
        Flow.Interview myFlowOmnniUICards = Flow.Interview.createInterview('OmniPackaging','Import_Omni_Components_OmniUICards', Params);
        myFlowOmnniUICards.start();
    
        Flow.Interview myFlowOmniProcessesAndRelated = Flow.Interview.createInterview('OmniPackaging','Insert_Records_for_OmniProcessElements', new Map<String, Object>());
        myFlowOmniProcessesAndRelated.start();
    
        Flow.Interview myFlowOmniTransformationsAndRelated = Flow.Interview.createInterview('OmniPackaging','Import_Omni_Components_OmniDataTransformation_and_OmniDataTransformationItems', new Map<String, Object>());
        myFlowOmniTransformationsAndRelated.start(); 
    }
  }