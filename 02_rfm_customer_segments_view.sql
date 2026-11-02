create view rfm_customer_segments_view as 
with rfm_base as(
select 
customerId,
(select max(invoiceDate) +INTERVAL '1 day' from cleaned_transactions_view)-max(invoiceDate) as recency,
count(distinct invoiceNumber) as frequency,
sum(totalAmount) as monetary
from cleaned_transactions_view
group by customerId
),
rfm_scores as(
select *,
ntile(4) over (order by recency desc) as r_score,
ntile(4) over (order by frequency asc) as f_score,
ntile(4) over (order by monetary asc) as m_score
from rfm_base
)
select *,
concat(r_score,f_score,m_score) as rfm_scores,
case 
when recency > interval '90 days' then 'Lost'
when concat(r_score,f_score,m_score) in ('444','434','443','344') then 'Champions'
when r_score >=3 and f_score >=3 then 'Loyal'
when r_score>=4 and f_score<=1 then 'New'
when r_score  in (2,3) and f_score  in (1,2) then 'Needs Attention'
else 'At Risk'
end as segment
from rfm_scores
