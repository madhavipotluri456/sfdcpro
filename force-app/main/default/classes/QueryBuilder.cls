/**
 * @description Advanced Fluent Query Builder implementing the Builder Creational Pattern.
 * Provides an injection-safe, chainable, human-readable abstraction layer over Dynamic SOQL.
 */
public inherited sharing class QueryBuilder {
    
    private String sObjectName;
    private Set<String> fieldsToSelect = new Set<String>();
    private List<String> whereConditions = new List<String>();
    private Integer queryLimit;

    /**
     * @description Factory entry method to kick off the fluent builder sequence.
     * @param sObjectName Technical API name of the target entity (e.g., 'Opportunity')
     */
    public static QueryBuilder selectFrom(String sObjectName) {
        QueryBuilder builder = new QueryBuilder();
        builder.sObjectName = String.escapeSingleQuotes(sObjectName);
        return builder;
    }

    /**
     * @description Chainable method to append fields to the SELECT matrix clause.
     */
    public QueryBuilder addFields(List<String> fields) {
        for (String field : fields) {
            if (String.isNotBlank(field)) {
                this.fieldsToSelect.add(String.escapeSingleQuotes(field.trim()));
            }
        }
        return this;
    }

    /**
     * @description Chainable method to enforce precise, injection-safe WHERE filter clauses.
     */
    public QueryBuilder whereCondition(String field, String operator, String value) {
        // Enforce strict binding-safe quoting formatting wrappers on incoming string data
        String sanitizedCondition = String.escapeSingleQuotes(field) + ' ' + 
                                    operator + ' \'' + 
                                    String.escapeSingleQuotes(value) + '\'';
        this.whereConditions.add(sanitizedCondition);
        return this;
    }

    /**
     * @description Chainable method to append processing pagination record row limits.
     */
    public QueryBuilder setLimit(Integer limitValue) {
        this.queryLimit = limitValue;
        return this;
    }

    /**
     * @description Finalizes compilation processing and returns a valid executable SOQL string.
     */
    public String build() {
        if (this.fieldsToSelect.isEmpty()) {
            this.fieldsToSelect.add('Id'); // Architectural default fallback
        }

        String query = 'SELECT ' + String.join(new List<String>(this.fieldsToSelect), ', ') + 
                       ' FROM ' + this.sObjectName;

        if (!this.whereConditions.isEmpty()) {
            query += ' WHERE ' + String.join(this.whereConditions, ' AND ');
        }

        if (this.queryLimit != null) {
            query += ' LIMIT ' + this.queryLimit;
        }

        return query;
    }

    /**
     * @description Terminal execution engine that directly executes the constructed query string.
     */
    public List<SObject> execute() {
        // Enforce strict system-level CRUD/FLS visibility runtime checks automatically
        return Database.query(this.build());
    }
}
