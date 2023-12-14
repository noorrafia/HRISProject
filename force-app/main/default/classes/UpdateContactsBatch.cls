global class UpdateContactsBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public integer batchrrecords=1;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, FirstName, LastName, Email,Allocated_Slot__c
            FROM Contact
            WHERE Allocated_Slot__c = NULL
            LIMIT :batchrrecords
        ]);
       
    }
 global void execute(Database.BatchableContext BC, List<Contact> scope) {
    system.debug('scope' + scope.size());
    Integer totalMembers = 1;
    Integer membersPerSlot = 1;
    Integer slotsPerDay = 1;
    Integer membersAllocated = 0;
    Integer slotsAllocated = 0;
    Integer count = 0;
    List<Contact> con = new List<Contact>();
    while (membersAllocated < totalMembers) {
        Integer remainingMembers = totalMembers - membersAllocated;
        Integer currentSlotMembers = Math.min(membersPerSlot, remainingMembers);
        // Allocate currentSlotMembers to a slot or perform necessary actions
        for (Integer i = 0; i < currentSlotMembers; i++) {
            if (count < scope.size()) {
                Contact cont = scope[count];
                cont.Allocated_Slot__c = slotsAllocated + 1; // Incremented slot number
                count++;
                con.add(cont); // Add the updated contact to the list
            }
        }
        membersAllocated += currentSlotMembers;
        slotsAllocated++;
        // Debugging information
        System.debug('Allocated ' + currentSlotMembers + ' members to Slot ' + slotsAllocated);
    }
    System.debug('Total Contacts with Allocated Slots: ' + con.size());
    // Update the contacts in the list
    update con;
}
    global void finish(Database.BatchableContext BC) {
      database.executeBatch(new BatchToGetSlot());
    }
}