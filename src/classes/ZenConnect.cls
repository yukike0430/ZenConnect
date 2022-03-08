//test
global class ZenConnect {
    public ZenConnect() {

    }

    @InvocableMethod
    public static void createTicket(){
        Set<ID> ids = new Set<Id>();
        ids.add('00T5h00000auFnHEAU');
        multiTiket(ids);
    }

    @future(callout=true)
    public static void myFutureMethod(Set<Id> ids)
    {   
        List<Task> tasks = [select  Id , subject from task order by LastModifiedDate desc limit 1];

        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:zendeskapi/v2/tickets.json');
        req.setMethod('POST');

        req.setHeader('Content-Type', 'application/json');

        req.setBody('{"ticket": {"subject": "'+tasks.get(0).Subject+'", "comment": { "body": "世界はこんなにも美しい" }}}');
     
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug(res.getBody());

        // for(Task t : tasks){
        //     t.Subject = t.Subject + 'aa';
        // }
        // update tasks;
    }

    @future(callout=true)
    public static void multiTiket(Set<Id> ids)
    {   
        List<Task> tasks = [select  Id , subject,owner.email from task order by LastModifiedDate desc limit 3];

        HttpRequest req = new HttpRequest();

        req.setEndpoint('callout:zendeskapi/tickets/create_many.json');
        req.setMethod('POST');
        
        req.setHeader('Content-Type', 'application/json');

        List<ZenTiket> tickets = new List<ZenTiket>();
        for (Task t : tasks) {
            ZenTiket zt = new ZenTiket();
            zt.subject = t.Subject;
            zt.status = 'new';
            zt.assignee_email = t.Owner.email;
            ZenComment zc = new ZenComment();
            zc.body = 'hogehoge';
            zt.comment = zc;
            tickets.add(zt);
        }

        System.debug(JSON.serialize(tickets));
        req.setBody('{"tickets": ' +JSON.serialize(tickets)+'}');

        //req.setBody('{"tickets": {"subject": "'+tasks.get(0).Subject+'", "comment": { "body": "世界はこんなにも美しい" }}}');
     
        Http http = new Http();
        //HTTPResponse res = http.send(req);
        //System.debug(res.getBody());

       // ZenJobResponse tiketsResponse =(ZenJobResponse) JSON.deserialize(res.getBody(), ZenJobResponse.class);
        // for(Task t : tasks){
        //     t.Subject = t.Subject + 'aa';
        // }
        //update tasks;
        HttpRequest req2 = new HttpRequest();
        //req2.setEndpoint('callout:zendeskapi/job_statuses/'+tiketsResponse.job_status.id+'.json');
        req2.setEndpoint('callout:zendeskapi/job_statuses/855804b294612025e8025a6f320aa0a1.json');
        

        req2.setMethod('GET');

        Http http2 = new Http();
        HTTPResponse res2 = http.send(req2);
        System.debug(res2.getBody());
    }

    public class ZenTiket{
        public String subject;
        public String status;
        public String assignee_email;
        public String external_id;
        public ZenComment comment;
    }

    public class ZenComment{
        public String body;
    }

    public class JobStatus{
        public String id;
        public String url;
        public String total;
        public String progress;
        public String status;
        public String message;
        public String results;
    }

    public class ZenJobResponse{
        public JobStatus job_status;
    }
}