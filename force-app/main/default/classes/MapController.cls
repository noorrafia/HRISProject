public class MapController {
    public Map<String, List<String>> myMap { get; set; }
        public Map<String, List<String>> selectedValues { get; set; }
        public Map <String,string> mapCorrectAns = new Map<String,string>();
        public List<ExaminationQuestion__c> objRecordResult;
        public Set<Id> setOfcontRecordResult = new Set<Id>();
        public List<contact> objcontRecordResult;
        public String userEmail { get; set; }
        public String userName { get; set; }
        public Boolean displayPopUp{get; set;}
        public Boolean displayPopUpForSuscces{get; set;}
        public Boolean displayPopUpForReject{get; set;} 
        public Boolean displayDetile{get; set;}
        public Boolean displayExmForm{get; set;}
        public Boolean errorMessage{get; set;}
        public string contactEmail ; 
        public List<Questions_answers__mdt> qns = [SELECT Id, Answer__c, Options__c, Questions__c FROM Questions_answers__mdt];
        
        public MapController() {
            displayDetile= true;
            displayExmForm= false;
            myMap = new Map<String, List<String>>();
            for(Questions_answers__mdt var : qns) {
                String commaSeparatedString = var.Options__c;
                List<String> stringList = commaSeparatedString.split(',');
              myMap.put(var.Questions__c, stringList);
                mapCorrectAns.put(var.Questions__c, var.Answer__c);
            }
            selectedValues = new Map<String, List<String>>();
            for (String key : myMap.keySet()) {
                selectedValues.put(key, new List<String>());
            }
        }
        public PageReference submitForm() {
            displayDetile =false;
            contactEmail = userEmail;
            List<contact> obj = [select Id, Number_of_answered__c,Interview_status__c,Email from contact where Email=:contactEmail];
            
            if(obj.isEmpty()){
               errorMessage = true;
            }
            if(!obj.isEmpty() && (obj[0].Email ==contactEmail)){
               displayExmForm= true;
            }
            return null;
        }
       // Provide map entries for iteration in the Visualforce page
         public List<MapEntry> getMapEntries() {
            List<MapEntry> entries = new List<MapEntry>();
            for (String key : myMap.keySet()) {
                entries.add(new MapEntry(key, myMap.get(key)));
            }
            return entries;
        }
        public void backToLogin(){
            errorMessage =false;
            displayDetile = true;
        }
        // Action method to handle form submission
        public void submitData() {
            Map<String, String> correctAnswers = new Map<String, String>();
            Integer counNoOfCorrectAns = 0;
            Integer counNoOfWrongAns = 0;
            Integer totalNoOfselectedAns = 0;
            system.debug('size = '+selectedValues.size());
            objRecordResult = new List<ExaminationQuestion__c>();
            
            objcontRecordResult = [select Id, Number_of_answered__c,Interview_status__c from contact where Email=:contactEmail];
    
            if(!objcontRecordResult.isEMpty()){
    
            for(contact objId : objcontRecordResult){
                if(objId.Id!=null)
                setOfcontRecordResult.add(objId.Id);
            }
            }
    
            for (String key : selectedValues.keySet()) {
                List<String> values = selectedValues.get(key);
                ExaminationQuestion__c objExam = new ExaminationQuestion__c();
                objExam.Question__c = key;
                objExam.Contact__c = objcontRecordResult[0].Id;
                objExam.Answer__c = String.join(values,'');
                Insert objExam;
            }
            
            objRecordResult = [SELECT Id, Answer__c, Question__c, Contact__c FROM ExaminationQuestion__c where Contact__c IN: setOfcontRecordResult];
    
            for (ExaminationQuestion__c obj : objRecordResult) {
                correctAnswers.put(obj.Question__c, obj.Answer__c);
            }
            // Compare answers
            for (Questions_answers__mdt objANS : qns) {
                if (correctAnswers.containsKey(objANS.Questions__c)) {
                    String correctAnswer = correctAnswers.get(objANS.Questions__c);
                    if (objANS.Answer__c == correctAnswer) {
                        counNoOfCorrectAns++;
                        if(counNoOfCorrectAns>=3){
                            displayPopUp=true;
                            displayPopUpForReject = false;
                            displayExmForm= false;
                        }
                    } else {
                        counNoOfWrongAns++;
                        displayPopUp=false;
                        displayExmForm= false;
                        displayPopUpForReject = true;
                    }
                } else {
    
                    System.debug('Correct answer not found for question: ' + objANS.Questions__c);
                }
            }
             for(contact objCont : objcontRecordResult){
                if(counNoOfCorrectAns>=3){
                    objCont.Number_of_answered__c = counNoOfCorrectAns;
                    objCont.Interview_status__c = 'FirstRound Cleared';
                    } else {
                        objCont.Number_of_answered__c = counNoOfCorrectAns;
                    objCont.Interview_status__c = 'FirstRound Rejected';
                    }
            }
            if(!objcontRecordResult.isEmpty() && objcontRecordResult !=null){
                UPDATE objcontRecordResult;
            } 
    
        }
        // Inner class to represent a map entry for iteration
        public class MapEntry {
            public String key { get; set; }
            public List<SelectOption> values { get; set; }
            public MapEntry(String key, List<String> mapValues) {
                this.key = key;
                this.values = new List<SelectOption>();
                for (String value : mapValues) {
                    this.values.add(new SelectOption(value, value));
                }
            }
        }
    }