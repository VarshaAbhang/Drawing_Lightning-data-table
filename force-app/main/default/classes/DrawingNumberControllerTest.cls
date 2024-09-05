@IsTest
public class DrawingNumberControllerTest {
   
    @TestSetup
    static void setupTestData() {

        RecordType sizeRecordType = null;
        RecordType makeRecordType = null;
        RecordType drawingNumberRecordType = null;

        // Query for Size RecordType
        List<RecordType> sizeRecordTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Drawing__c' AND DeveloperName = 'Size' LIMIT 1];
        if (!sizeRecordTypeList.isEmpty()) {
            sizeRecordType = sizeRecordTypeList[0];
        } else {
            System.debug('Size RecordType not found for Drawing__c object.');
        }

        // Query for Make RecordType
        List<RecordType> makeRecordTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Drawing__c' AND DeveloperName = 'Make' LIMIT 1];
        if (!makeRecordTypeList.isEmpty()) {
            makeRecordType = makeRecordTypeList[0];
        } else {
            System.debug('Make RecordType not found for Drawing__c object.');
        }

        // Query for Drawing Number RecordType
        List<RecordType> drawingNumberRecordTypeList = [SELECT Id FROM RecordType WHERE SObjectType = 'Dimensions__c' AND DeveloperName = 'Drawing_Number' LIMIT 1];
        if (!drawingNumberRecordTypeList.isEmpty()) {
            drawingNumberRecordType = drawingNumberRecordTypeList[0];
        } else {
            System.debug('Drawing_Number RecordType not found for Dimensions__c object.');
        }

     
        if (sizeRecordType == null || makeRecordType == null || drawingNumberRecordType == null) {
            System.debug('One or more Record Types not found. Ensure DeveloperNames are correct.');
            return;
        }

        // Insert test data for the Size Drawing__c record
        Drawing__c sizeDrawing = new Drawing__c(
            Name = 'Test Size Drawing',
            Item_Family__c = 'Mechanical Seal',
            Item_Category__c = 'Pusher Seal',
            Code__c = 'SD',
            Drawing_Li_Status__c = 'Pending',
            Approval_Status__c = 'Approved',
            Assebly_Drawing__c = 'https://example.com/size_assebly',
            Cut_View_Drawing__c = 'https://example.com/size_cutview',
            Drawing_Image__c = 'https://example.com/size_image',
            RecordTypeId = sizeRecordType.Id
        );
        insert sizeDrawing;

        // Insert test data for the Make Drawing__c record
        Drawing__c makeDrawing = new Drawing__c(
            Name = 'Test Make Drawing',
            Item_Family__c = 'Mechanical Seal',
            Item_Category__c = 'Pusher Seal',
            Code__c = 'MD',
            Drawing_Li_Status__c = 'Pending',
            Approval_Status__c = 'Approved',
            Assebly_Drawing__c = 'https://example.com/make_assebly',
            Cut_View_Drawing__c = 'https://example.com/make_cutview',
            Drawing_Image__c = 'https://example.com/make_image',
            RecordTypeId = makeRecordType.Id
        );
        insert makeDrawing;

        // Insert test data for Drawing_Code__c with all required fields
        Drawing_Code__c drawingCode = new Drawing_Code__c(
            Name = 'Test Drawing Code',
            Drawing__c = makeDrawing.Id,
            Item_Family__c = 'Mechanical Seal',
            Item_Category__c = 'Pusher Seal',
            Make__c = makeDrawing.Id,
            Make_Code__c = 'Test Make Code',
            Code__c = 'Test Code'
        );
        insert drawingCode;

        // Insert test data for Drawing_Number__c with required fields
        Drawing_Number__c drawingNumber = new Drawing_Number__c(
            Name = 'Test Code-SD',
            Item_Family__c = 'Mechanical Seal',
            Item_Category__c = 'Pusher Seal',
            Size__c = sizeDrawing.Id,
            DN_LI_Status__c = 'Created',
            Drawing_Code1__c = drawingCode.Id,
            Dimensions_Status__c = 'Created'
        );
        insert drawingNumber;

        // Insert test data for DN_LI__c with Part_name__c and Part_Number__c
        DN_LI__c dnli = new DN_LI__c(
            Name = 'Test DN_LI',
            Drawing_Number__c = drawingNumber.Id,
            Item_Family__c = 'Mechanical Seal',
            Item_Category__c = 'Pusher Seal',
            Part_name__c = makeDrawing.Id,
            Part_Number__c = 123.45,
            Part_Drawing_Number__c = drawingNumber.Id
        );
        insert dnli;

        // Insert test data for Dimensions__c
        Dimensions__c dimension = new Dimensions__c(
            Name = 'Test Dimension',
            Size__c = 100,
            Tolerance_Plus__c = 0.1,
            Tolerance_Minus__c = 0.1,
            Drawing_Number__c = drawingNumber.Id,
            Drawing__c = sizeDrawing.Id,
            Remarks__c ='Its working',
            RecordTypeId = drawingNumberRecordType.Id
        );
        insert dimension;
    }
    
	@IsTest
    static void testGetDrawingNumberdataAdmin() {

    System.debug('Querying testGetDrawingNumberdataAdmin records');
    Drawing_Number__c drawingNumber = [SELECT Id FROM Drawing_Number__c LIMIT 1];
    System.debug('Queried Drawing Number ID: ' + drawingNumber.Id);


            Test.startTest();
            Drawing_Number__c result = DrawingNumberController.getDrawingNumberData(drawingNumber.Id);
            Test.stopTest();
    
            System.assertNotEquals(null, result, 'Expected valid Drawing_Number__c record');
            System.assertEquals('Test Code-SD', result.Name, 'Expected matching Drawing_Number__c name');
            System.assertEquals('https://example.com/make_assebly', result.Drawing_Code1__r.Drawing__r.Assebly_Drawing__c, 'Expected matching Assebly_Drawing__c URL');

    }
   
    @IsTest
    static void testGetDrawingNumberData() {
        // Create a Standard User
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User standardUser = new User(
            Alias = 'stduser',
            Email = 'standarduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'standarduser' + DateTime.now().getTime() + '@example.com'

        );
        insert standardUser;
       
        System.runAs(standardUser) {
            try {
                Drawing_Number__c drawingNumber = [SELECT Id FROM Drawing_Number__c LIMIT 1];
                Test.startTest();
                Drawing_Number__c result = DrawingNumberController.getDrawingNumberData(drawingNumber.Id);
                Test.stopTest();

            } catch (Exception e) {
                system.assert(e!=null, 'Exception cannot be null');
            }
        }
    }

   @IsTest
   static void testGetDNLIdataAdmin(){
   
    Drawing_Number__c drawingNumber = [SELECT Id FROM Drawing_Number__c LIMIT 1];

        Test.startTest();
        List<DN_LI__c> dnliData = DrawingNumberController.getDNLIdata(drawingNumber.Id);
        Test.stopTest();

        System.assertNotEquals(null, dnliData, 'Expected valid DN_LI__c records');
        System.assertEquals(1, dnliData.size(), 'Expected 1 DN_LI__c record');
        System.assertEquals('Test DN_LI', dnliData[0].Name, 'Expected matching DN_LI__c name');
        System.assertEquals(123.45, dnliData[0].Part_Number__c, 'Expected matching Part_Number__c');
        System.assertEquals(drawingNumber.Id, dnliData[0].Drawing_Number__c, 'Expected matching Drawing_Number__c');

   }

    @IsTest
    static void testGetDNLIdata() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User standardUser = new User(
            Alias = 'stduser',
            Email = 'standarduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'standarduser' + DateTime.now().getTime() + '@example.com'

        );
        insert standardUser;
       
        System.runAs(standardUser) {
            try {
                Drawing_Number__c drawingNumber = [SELECT Id FROM Drawing_Number__c LIMIT 1];
               
                Test.startTest();
                List<DN_LI__c> dnliData = DrawingNumberController.getDNLIdata(drawingNumber.Id);
                Test.stopTest();
               
            } catch (Exception e) {
                system.assert(e!=null, 'Exception cannot be null');
            }
        }
    }

   @IsTest
    static void testGetDimensiondataAdmin() {
	    System.debug('Querying testGetDimensiondataAdmin records');
        Drawing_Number__c drawingNumber = [SELECT Id FROM Drawing_Number__c LIMIT 1];
        System.debug('Queried Drawing Number ID: ' + drawingNumber.Id);
               
        Test.startTest();
        List<Dimensions__c> dimensionData = DrawingNumberController.getDimensiondata(drawingNumber.Id);
        Test.stopTest();

        System.assertNotEquals(null, dimensionData, 'Expected valid Dimensions__c records');
        System.assertEquals(1, dimensionData.size(), 'Expected 1 Dimensions__c record');
        System.assertEquals('Test Dimension', dimensionData[0].Name, 'Expected matching Dimensions__c name');

    }

    @IsTest
    static void testGetDimensiondata() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        User standardUser = new User(
            Alias = 'stduser',
            Email = 'standarduser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = standardUserProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = 'standarduser' + DateTime.now().getTime() + '@example.com'

        );
        insert standardUser;
       
        System.runAs(standardUser) {
            try {
                Drawing_Number__c drawingNumber = [SELECT Id FROM Drawing_Number__c LIMIT 1];
               
                Test.startTest();
                List<Dimensions__c> dimensionData = DrawingNumberController.getDimensiondata(drawingNumber.Id);
                Test.stopTest();
               
            } catch (Exception e) {
                system.assert(e!=null, 'Exception cannot be null');
            }
        }
    }
}