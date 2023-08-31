/*Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock bands*/
--artist->album->track->genre 
select artist.artist_id , artist.name, COUNT(track.track_id) AS num
from track
join album ON album.album_id = track.album_id
join artist ON artist.artist_id = album.album_id
join genre ON genre.genre_id = track.genre_id
WHERE genre.name = 'Rock'
group by artist.artist_id
order by num  desc
limit 10;





/*Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent*/

-- using CTE
--store best selling artist
WITH best_selling_artist as (
	--calculate the total_sales from invoic_line unitprice*qauntity
   Select artist.artist_id as artist_id, artist.name as artist_name ,
	SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
   from invoice_line
	join track ON track.track_id = invoice_line.track_id
	join album ON album.album_id = track.album_id
	join artist ON artist.artist_id = album.artist_id
	Group by 1
	order by 3 desc
	limit 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;







/*Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first*/
select name, milliseconds
from track
where milliseconds > (
    select AVG(milliseconds) As avg_time
	from track
	
)
order by milliseconds desc


/*We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres*/

With popular_genre AS(
	Select COUNT(invoice_line.quantity) AS purchases, customer.country,genre.name, genre.genre_id,
	ROW_NUMBER() OVER(Partition By customer.country Order By COUNT(invoice_line.quantity) DESC) AS RowNo
  	from invoice_line
	join invoice ON invoice.invoice_id = invoice_line.invoice_id
	join customer ON customer.customer_id = invoice.customer_id
	join track ON track.track_id = invoice_line.track_id
	join genre ON genre.genre_id = track.genre_id
	Group by 2,3,4
	order by 2 asc, 1 desc
	

)

select * from popular_genre WHERE RowNo <= 1



/*Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount*/

WITH RECURSIVE 
	customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1;


