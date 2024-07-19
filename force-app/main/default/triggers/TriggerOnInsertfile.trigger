trigger TriggerOnInsertfile on ContentVersion (after insert) {
    switch on Trigger.operationType{
        
        when AFTER_INSERT{
            insertFileHandler.getContactId(Trigger.new);
        }
        
    } 

}