public inherited sharing class DealDeskRemotingProvider {
    
    // Fluent Injection-Safe Query Builder Section
    private String fieldsStr;
    private String targetObject;

    public static DealDeskRemotingProvider queryFactory() {
        return new DealDeskRemotingProvider();
    }
    public DealDeskRemotingProvider selectFields(String fields) {
        this.fieldsStr = fields;
        return this;
    }
    public DealDeskRemotingProvider fromEntity(String entity) {
        this.targetObject = entity;
        return this;
    }
    public String compileSOQL() {
        return 'SELECT ' + String.escapeSingleQuotes(fieldsStr) + ' FROM ' + String.escapeSingleQuotes(targetObject) + ' LIMIT 100';
    }

    // JavaScript Remoting Micro-Gateway bypassing 5MB limits
    @RemoteAction
    public static List<Opportunity> fetchLedgerData() {
        String dynamicQuery = DealDeskRemotingProvider.queryFactory()
            .selectFields('Id, Name, StageName, Amount')
            .fromEntity('Opportunity')
            .compileSOQL();
        return Database.query(dynamicQuery);
    }

    // Mass-Edit Savepoint Transaction Handling
    @RemoteAction
    public static String commitLedgerChanges(List<Opportunity> recordsToUpdate) {
        Savepoint databaseCheckpoint = Database.setSavepoint();
        try {
            update recordsToUpdate;
            return 'Transaction Committed Successfully.';
        } catch (Exception ex) {
            Database.rollback(databaseCheckpoint);
            return 'Fatal DML Error. Rollback Enforced: ' + ex.getMessage();
        }
    }
}
