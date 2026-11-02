
drop table if exists staged_transactions2010;
create table staged_transactions2010 (
    invoice VARCHAR,
	stockCode varchar,
	description varchar,
	quantity varchar,
    invoiceDate varchar,
    price varchar,
    customerId VARCHAR,
	country varchar
)


drop table if exists staged_transactions2011
create table staged_transactions2011 (
    invoice VARCHAR,
	stockCode varchar,
	description varchar,
	quantity varchar,
    invoiceDate varchar,
    price varchar,
    customerId VARCHAR,
	country varchar
)

--creating view that is used for like a prewriitten code which will help me if i move the data in BI or other way these code willrun and cleaning is done so i don't need to do it again 
drop view if exists cleaned_transactions_view cascade;
create view cleaned_transactions_view as 
with combinedTable as(
select customerId,invoiceDate,invoice,quantity,price,country 
from staged_transactions2010
union all
select customerId, invoiceDate, invoice, quantity, price,country
from staged_transactions2011
)
select 
trim(customerId) as customerId,

case
        when trim(invoiceDate) ~ '^\d{4}' 
            then to_timestamp(trim(invoiceDate), 'YYYY-MM-DD HH24:MI')::date
            
        when trim(invoiceDate) ~ '^(1[3-9]|2[0-9]|3[01])[-/]' 
            then to_timestamp(trim(invoiceDate), 'DD-MM-YYYY HH24:MI')::date
            
        when trim(invoiceDate) ~ '^\d{1,2}[-/](1[3-9]|2[0-9]|3[01])[-/]' 
            then to_timestamp(trim(invoiceDate), 'MM-DD-YYYY HH24:MI')::date
            
        else to_timestamp(trim(invoiceDate), 'DD-MM-YYYY HH24:MI')::date
    end as invoiceDate,
trim(invoice) as invoiceNumber,
cast(quantity as decimal(10,2))*cast (price as decimal(10,2)) as totalAmount,
trim(country) as country
from  combinedTable
where
nullif(trim(customerId),'') is not null
and
nullif(trim(invoiceDate), '') is not null
and 
cast(quantity as decimal(10,2))>0