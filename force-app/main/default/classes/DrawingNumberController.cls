public without sharing class DrawingNumberController {
    
    @AuraEnabled(cacheable=true)
    public static Drawing_Number__c getDrawingNumberData(Id drawingNumberId) {
        if (!Schema.sObjectType.Drawing_Number__c.isAccessible()) {
            throw new System.NoAccessException();
        }
    
        try {
            Drawing_Number__c drawingNumber = [
                SELECT Id, Name, 
                        Drawing_Code1__r.Name, 
                        Drawing_Code1__r.Drawing__r.Assebly_Drawing__c,
                        Drawing_Code1__r.Drawing__r.Cut_View_Drawing__c,
                        Drawing_Code1__r.Drawing__r.Drawing_Image__c,
                        Demo_image__c
                FROM Drawing_Number__c 
                WHERE Id = :drawingNumberId
                LIMIT 1 
            ];
    
            return drawingNumber;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    @AuraEnabled(cacheable=true)
    public static List<DN_LI__c> getDNLIdata(Id drawingNumberId) {
        if (!Schema.sObjectType.DN_LI__c.isAccessible()) {
            throw new System.NoAccessException();
        }

        try {
            return [
                SELECT Id, Drawing_Number__r.Name, Name, Item_Family__c, Item_Category__c, Part_Number__c, Part_name__r.Name, Part_Drawing_Number__r.Name
                FROM DN_LI__c
                WHERE Drawing_Number__c = :drawingNumberId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Dimensions__c> getDimensiondata(Id drawingNumberId) {
        if (!Schema.sObjectType.Dimensions__c.isAccessible()) {
            throw new System.NoAccessException();
        }

        try {
            return [
                SELECT Id, Name, Size__c, Tolerance_Plus__c, Tolerance_Minus__c,Drawing_Number__r.Name,Drawing__r.Name,RecordType.Name, Remarks__c FROM Dimensions__c
                WHERE Drawing_Number__c = :drawingNumberId
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
   
    

}
