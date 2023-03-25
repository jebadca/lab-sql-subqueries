USE sakila;

#1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(inv.inventory_id) as num_copies
FROM film f
JOIN inventory inv
ON f.film_id = inv.film_id
WHERE f.title LIKE "Hunchback Impossible"
GROUP BY f.title;

#2.List all films whose length is longer than the average of all the films.

SELECT title, length
FROM film
WHERE length > (
	SELECT AVG(length)
	FROM film 
);

#3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT a.first_name, a.last_name, a.actor_id
FROM actor a
JOIN (
	SELECT actor_id, film_id
	FROM film_actor
	WHERE film_id = (
		SELECT film_id
		FROM film
		WHERE title = "Alone Trip"
	)
) fa ON a.actor_id = fa.actor_id;

#4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT *
FROM category;

SELECT title, f.film_id
FROM film f
JOIN (
	SELECT film_id, category_id
    FROM film_category
    WHERE category_id = (
		SELECT category_id
		FROM category
		WHERE name = "Family"
	)
) cat
ON f.film_id = cat.film_id;

#5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id IN (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);

#6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_actor
    WHERE actor_id IN (
        SELECT actor_id
        FROM film_actor
        GROUP BY actor_id
        HAVING COUNT(*) = (
            SELECT MAX(actor_count)
            FROM (
                SELECT COUNT(*) AS actor_count
                FROM film_actor
                GROUP BY actor_id
            ) t
        )
    )
);

#7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT film.title
FROM film
WHERE film.film_id IN (
    SELECT inventory.film_id
    FROM inventory
    WHERE inventory.inventory_id IN (
        SELECT rental.inventory_id
        FROM rental
        WHERE rental.rental_id IN (
            SELECT payment.rental_id
            FROM payment
            WHERE payment.customer_id = (
                SELECT customer.customer_id
                FROM customer
                WHERE customer.customer_id = (
                    SELECT payment.customer_id
                    FROM payment
                    GROUP BY payment.customer_id
                    ORDER BY SUM(payment.amount) DESC
                    LIMIT 1
                )
            )
        )
    )
)

SELECT payment.customer_id AS client_id, SUM(payment.amount) AS total_amount_spent
FROM payment
WHERE payment.customer_id IN (
    SELECT customer.customer_id
    FROM customer
    WHERE customer.customer_id IN (
        SELECT payment.customer_id
        FROM payment
        GROUP BY payment.customer_id
        HAVING SUM(payment.amount) > (
            SELECT AVG(subquery.total_amount_spent)
            FROM (
                SELECT payment.customer_id, SUM(payment.amount) AS total_amount_spent
                FROM payment
                GROUP BY payment.customer_id
            ) AS subquery
        )
    )
)

#8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client.
SELECT payment.customer_id AS client_id, SUM(payment.amount) AS total_amount_spent
FROM payment
WHERE payment.customer_id IN (
    SELECT customer.customer_id
    FROM customer
    WHERE customer.customer_id IN (
        SELECT payment.customer_id
        FROM payment
        GROUP BY payment.customer_id
        HAVING SUM(payment.amount) > (
            SELECT AVG(subquery.total_amount_spent)
            FROM (
                SELECT payment.customer_id, SUM(payment.amount) AS total_amount_spent
                FROM payment
                GROUP BY payment.customer_id
            ) AS subquery
        )
    )
)
GROUP BY payment.customer_id;
