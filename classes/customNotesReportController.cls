public class customNotesReportController {
    
    //Get data for filter : setObjectName, setRecordName, setCreatedBy, setLastReviewBy
    
    @AuraEnabled
    public static List<List<String>> getAllDataForFilter(){
        List<ContentNote> listContentNotes = [SELECT Id FROM ContentNote];

        Set<Id> setIdContentNote = new Set<Id>();
        
        List<List<String>> filterData = new List<List<String>>();
    
        if(listContentNotes.size() != 0) {

                for(ContentNote iter : listContentNotes) {
                    setIdContentNote.add(iter.Id);
                }
            
            List<ContentDocument> contentDocList =  [Select 
                                                    Title,
                                                    LastModifiedById,
                                                    LastModifiedBy.Name,
                                                    LastViewedDate,
                                                    CreatedById,
                                                    CreatedBy.Name,
                                                    CreatedDate,
                                                    Description,
                                                    (select id, ContentDocumentID, LinkedEntityId, LinkedEntity.Name from ContentDocumentLinks),
                                                    (select id, TextPreview from ContentVersions ),
                                                    id from ContentDocument
                                                    where
                                                    id in :setIdContentNote];

            
            System.debug('contentDocList' + contentDocList);
            
            Set<Id> seIdUsers = new Set<Id>();
            
            Set<String> setObjectName = new Set<String>();
            Set<String> setRecordName = new Set<String>();
            Set<String> setCreatedBy = new Set<String>();
            Set<String> setLastReviewBy = new Set<String>();
            
            for(ContentDocument cd : contentDocList){
                if (cd.ContentDocumentLinks.size() != 0) {
                    for(ContentDocumentLink cdd :cd.ContentDocumentLinks){
    
                       String sobjectName  = cdd.LinkedEntityId.getSobjectType().getDescribe().getLabel();
    
                        if(sobjectName != 'User'){
                            setObjectName.add(sobjectName);
                            setRecordName.add(cdd.LinkedEntity.Name);
                            setCreatedBy.add(cd.CreatedBy.Name);
                            setLastReviewBy.add(cd.LastModifiedBy.Name);
                           
                        }              
                    }
                } else {
                    setObjectName.add('_blank');
                }
            }
            List<String> listObjectName = new List<String>(setObjectName);
            List<String> listRecordName = new List<String>(setRecordName);
            List<String> listCreatedBy = new List<String>(setCreatedBy);
            List<String> listLastReviewBy = new List<String>(setLastReviewBy);
            
			filterData.add(listObjectName);
            filterData.add(listRecordName);  
            filterData.add(listCreatedBy);  
            filterData.add(listLastReviewBy);  
            
            
        }
        System.debug('filterData : ' + filterData);
        return filterData;
    }

    // Get first 100 Notes : Scrolling for datatable
    
    @AuraEnabled
    public static Map<String, List<ContentDocument>> notesListUpdate(Integer intOffSet) {
        
        Map<String, List<ContentDocument>> mapContentNote = new Map<String, List<ContentDocument>>();
        
        List<ContentNote> listContentNotes = [SELECT Id FROM ContentNote];

        Set<Id> setIdContentNote = new Set<Id>();
        
        
                if(listContentNotes.size() != 0) {
    
                    for(ContentNote iter : listContentNotes) {
                        setIdContentNote.add(iter.Id);
                    }
                }
        
        System.debug('setIdContentNote : ' + setIdContentNote.size());
        
        		List<ContentDocument> listCD = [Select Id,
                       Title,
                       LastModifiedById,
                       LastModifiedBy.Name,
                       LastViewedDate,
                       CreatedById,
                       CreatedBy.Name,
                       CreatedDate,
                       (select id, ContentDocumentID, LinkedEntityId, LinkedEntity.Name from ContentDocumentLinks),
                       (select id, TextPreview from ContentVersions ),
                       Description from ContentDocument 
                                   where id in :setIdContentNote ORDER BY createdDate DESC
                        		   LIMIT 50 OFFSET : Integer.valueOf(intOffSet)];
        
        System.debug('listCD : ' + listCD.size());
        
        for(ContentDocument cd : listCD){
            if (cd.ContentDocumentLinks.size() != 0) {

                for (ContentDocumentLink cdd : cd.ContentDocumentLinks) {
                    String sobjectName  = cdd.LinkedEntityId.getSobjectType().getDescribe().getLabel();
                    if (sobjectName != 'User') {
                        if(mapContentNote.containsKey(sobjectName)){
                                    List<ContentDocument> listLocal = mapContentNote.get(sobjectName);
                                    listLocal.add(cd);
                                    mapContentNote.put(sobjectName, listLocal);
                                } else {
                                    mapContentNote.put(sobjectName, new List<ContentDocument>{cd});
                                }
                    }
                }
            } else {

                String nosObject = '_blank';
                if(mapContentNote.containsKey(nosObject)){
                    List<ContentDocument> listLocal = mapContentNote.get(nosObject);
                                    listLocal.add(cd);
                                    mapContentNote.put(nosObject, listLocal);
                } else {
                    mapContentNote.put(nosObject, new List<ContentDocument>{cd});
                }
            }
        }
        
            System.debug('EE' + mapContentNote);

		return mapContentNote;
    }
    
    // Get filtered notes
    
	@AuraEnabled    
    public static Map<String, List<ContentDocument>> forDataByFilterCriteria(String keyWordNC, String fromPublishDate, String toPublishDate, String fromRevisedDate, String toRevisedDate, List<String> createdByName, List<String> lastRevisedBy, List<String> sObjectNameFilter, List<String> filterByRecordName){
        
           	Map<String, List<ContentDocument>> mapContentNote = new Map<String, List<ContentDocument>>();
        
        	List<ContentNote> listContentNotes = [SELECT Id FROM ContentNote];
        	Set<Id> setIdContentNote = new Set<Id>();
        
           	if(listContentNotes.size() != 0) {
    
                    for(ContentNote iter : listContentNotes) {
                        setIdContentNote.add(iter.Id);
                    }
                
                
                            					/*  [Select 
                                                    Title,
                                                    LastModifiedById,
                                                    LastModifiedBy.Name,
                                                    LastViewedDate,
                                                    CreatedById,
                                                    CreatedBy.Name,
                                                    CreatedDate,
                                                    Description,
                                                    (select id, ContentDocumentID, LinkedEntityId, LinkedEntity.Name from ContentDocumentLinks),
                                                    (select id, TextPreview from ContentVersions ),
                                                    id from ContentDocument
                                                    where
                                                    id in :setIdContentNote];
												*/
        
           	String query='Select Title,LastModifiedById,LastModifiedBy.Name,LastViewedDate,CreatedById,CreatedBy.Name,CreatedDate,Description,(select id, ContentDocumentID, LinkedEntityId, LinkedEntity.Name from ContentDocumentLinks),(select id, TextPreview from ContentVersions ),id from ContentDocument where id in :setIdContentNote';   

                if(createdByName.size() != 0)
                	query=query.replace(' where id in :setIdContentNote', ' where CreatedById in :createdByName');
            	if(lastRevisedBy.size() != 0)
                	query=query.replace(' where id in :setIdContentNote', ' where LastModifiedById in :lastRevisedBy');
            	if(fromPublishDate!=null )
                    query=query+' and createdDate >= '+fromPublishDate;
                if(toPublishDate!=null )
                    query=query+' and createdDate <= '+toPublishDate;
            	if(fromRevisedDate!=null )
                    query=query+' and LastViewedDate >= '+fromRevisedDate;
                if(toRevisedDate!=null )
                    query=query+' and LastViewedDate <= '+toRevisedDate;
            	if(filterByRecordName.size() != 0 )
                    query=query.replace('from ContentDocumentLinks', 'from ContentDocumentLinks where LinkedEntity.Name = :filterByRecordName' );
                
                query=query+' ORDER BY createdDate DESC';

                List<ContentDocument> localList = new List<ContentDocument>();
                
                if(keyWordNC != null){
                    Set<ContentDocument> localSet = new Set<ContentDocument>();
                    String keyWord = '%' + keyWordNC + '%';
                    query=query.replace(' where id in :setIdContentNote', ' where Title LIKE :keyWord');
                    
                    List<ContentDocument> queryList = Database.query(query);
                    

                        for(ContentDocument cd : queryList){
                           	   localSet.add(cd);
                        }
                    

                        query=query.replace(' where Title LIKE :keyWord', ' where id in :setIdContentNote');
                        query=query.replace('from ContentVersions', 'from ContentVersions WHERE TextPreview LIKE :keyWord');
                    	List<ContentDocument> localListTemp = Database.query(query);
                            for(ContentDocument cd : localListTemp){
                                if(!cd.ContentVersions.isEmpty()){
                                    localSet.add(cd);
                                }
                            }

					localList = new List<ContentDocument>(localSet);
                    
                    System.debug('localSet : ' + localSet);
                } else {
                    localList = Database.query(query);
                } 

            
            System.debug('query : ' + query);
            System.debug('localList : ' + localList.size());

                for(ContentDocument cd : localList){
                  if (cd.ContentDocumentLinks.size() != 0) {
                      
                    for(ContentDocumentLink cdd :cd.ContentDocumentLinks){
    
                       String sobjectName  = cdd.LinkedEntityId.getSobjectType().getDescribe().getLabel();
                        if(sObjectNameFilter.size() !=0){
                          for(String obj : sObjectNameFilter){
                            if(obj == sobjectName){
                                if(sobjectName != 'User'){
                                    
                                    if(mapContentNote.containsKey(sobjectName)){
                                        List<ContentDocument> listLocal = mapContentNote.get(sobjectName);
                                        listLocal.add(cd);
                                        mapContentNote.put(sobjectName, listLocal);
                                    } else {
                                        mapContentNote.put(sobjectName, new List<ContentDocument>{cd});
                                    }
                                }    
                                
                            }
                          }
                        } else {
                           if(sobjectName != 'User'){
                            
                            if(mapContentNote.containsKey(sobjectName)){
                                List<ContentDocument> listLocal = mapContentNote.get(sobjectName);
                                listLocal.add(cd);
                                mapContentNote.put(sobjectName, listLocal);
                            } else {
                                mapContentNote.put(sobjectName, new List<ContentDocument>{cd});
                            }
                          }  
                        }
                                         
                    }
                  } else {
                      
                      if(sObjectNameFilter.size() !=0){
                          for(String obj : sObjectNameFilter){
                              String nosObject = '_blank';
                              if(obj == nosObject){
                                    if(mapContentNote.containsKey(nosObject)){
                                        List<ContentDocument> listLocal = mapContentNote.get(nosObject);
                                                        listLocal.add(cd);
                                                        mapContentNote.put(nosObject, listLocal);
                                    } else {
                                        mapContentNote.put(nosObject, new List<ContentDocument>{cd});
                                    }
                              }
                          }
                      }
                      
                  }
                }
                System.debug('EE' + mapContentNote);
        	}
        	return mapContentNote;
        
    }         
}