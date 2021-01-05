@isTest
public class customNotesReportTest {
	    static testMethod void testgetAllDataForFilter (){
        
                    Contact c = new Contact();
                        c.LastName = 'Miller';
                        c.Phone = '00000000001';
                        c.Gender__c = 'Male';
                        c.Race_Ethnicity__c = 'Asian';
                
                    insert c;
                    System.debug('After insert c' + c);

                 	ContentNote cn = new ContentNote();
                    cn.Title = 'salesforce code crack';
                    cn.Content = Blob.valueOf('Welcome to salesforcecodecrack.com');
                    insert cn; //Insert Content Note   
                    System.debug('After insert cn : ' + cn);
            

                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = c.Id;  
                    cdl.ContentDocumentId = cn.Id;  
                    cdl.shareType = 'V'; 
                    insert cdl;
            		System.debug('After insert cdl : ' + cdl);

                Test.startTest();
            
            	//((Client and Contact), (Miller), (Hitesh Nangrani), (Hitesh Nangrani))   
			   List<List<String>> checkList = new List<List<String>>{
                                                                        new List<String>{'Client and Contact'},
                                                                        new List<String>{'Miller'},
                                                                        new List<String>{'Hitesh Nangrani'},
                                                                        new List<String>{'Hitesh Nangrani'}
                                                                    };
                
				System.debug('checkList : ' + checkList); 
            
            
            
            		List<List<String>> listTemp =  customNotesReportController.getAllDataForFilter();

                    System.debug('listTemp : ' + listTemp[0]);
            
             		System.assertEquals(listTemp, checkList);

            
                Test.stopTest();
			
    }
    
    static testMethod void testnotesListUpdate (){
        
        			Contact c = new Contact();
                    c.LastName = 'Miller';
                    c.Phone = '00000000001';
                    c.Gender__c = 'Male';
                    c.Race_Ethnicity__c = 'Asian';
                
                    insert c;
                    System.debug('After insert c' + c);


                 	ContentVersion cv = new ContentVersion();
                    cv.Title = 'Test Content Note';
                    cv.PathOnClient = cv.Title + '.snote';
                    cv.VersionData = Blob.valueOf('This is Test Content Note');
                    cv.FirstPublishLocationId = c.Id;  // ParentId
                    insert cv;
        			System.debug('After insert cv : ' + cv);
        
        			List<ContentDocument> cd = [SELECT Id, Title FROM ContentDocument LIMIT 1];
        
                    List<ContentDocumentLink> cdl = [select id, ContentDocumentID, LinkedEntityId from ContentDocumentLink WHERE ContentDocumentId =:cd[0].Id];
        			
        			System.debug('E### cd : ' + cd);
        			System.debug('E### cdl : ' + cdl);
        
        		Test.startTest();

            		Map<String, List<ContentDocument>> mapTemp =  customNotesReportController.notesListUpdate(0);

                    System.debug('mapTemp : ' + mapTemp);
            
             		System.assertEquals(1, mapTemp.size());

                Test.stopTest();
    }
    
    
    static testMethod void testforDataByFilterCriteria (){
        
        			Contact c = new Contact();
                    c.LastName = 'Miller';
                    c.Phone = '00000000001';
                    c.Gender__c = 'Male';
                    c.Race_Ethnicity__c = 'Asian';
                
                    insert c;
                    System.debug('After insert c' + c);


                 	ContentVersion cv = new ContentVersion();
                    cv.Title = 'Test Content Note';
                    cv.PathOnClient = cv.Title + '.snote';
                    cv.VersionData = Blob.valueOf('This is Test Content Note');
                    cv.FirstPublishLocationId = c.Id;  
                    insert cv;
        			System.debug('After insert cv : ' + cv);
        
        			ContentDocument cd = [SELECT Id, Title, CreatedDate FROM ContentDocument LIMIT 1];
        
                    List<ContentDocumentLink> cdl = [select id, ContentDocumentID, LinkedEntityId from ContentDocumentLink WHERE ContentDocumentId =:cd.Id];
        			
        			System.debug('E### cd : ' + cd);
        			System.debug('E### cdl : ' + cdl);
        
        		Test.startTest();
        
        			DateTime fromDate = System.today() - 3;
        System.debug('fromDate ########################## : ' + String.valueOf(fromDate));
        			DateTime todaysDate = System.today();
		 System.debug('todaysDate ########################## : ' + String.valueOf(todaysDate));
        
        
            System.debug('currentUser ########################## : ' + UserInfo.getName());
        
        			List<String> users = new List<String>{'Hitesh Nangrani'};
                    List<String> sObjects = new List<String>{'Client and Contact'};
                    List<String> filterByRecordName = new List<String>{'Test Content Note'};

                        Map<String, List<ContentDocument>> mapTemp =  customNotesReportController.forDataByFilterCriteria('test', null, null, null, null, new List<String>(), new List<String>(), new List<String>{'Client and Contact'}, new List<String>{'Miller'});

                    System.debug('mapTemp2 : ' + mapTemp);
            
             		System.assertEquals(1, mapTemp.size());

                Test.stopTest();
    }
}