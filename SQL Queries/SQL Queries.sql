/* Query 1 : **Concat** The company wants to send discount offers to all Freelancers who stay in New England Region. 
Find their Address, City and State details*/

SELECT f.UsersId, concat(f.HouseNumber, " ", f.StreetName, " ", f.StreetSuffix, ", ",
"ZipCode", "-", f.ZipCode) Address,
f.City, f.State
FROM freelancer f
WHERE f.state IN ('New Hampshire', 'Maine','Vermont','Massachusetts',
'Rhode Island','Connecticut');



/* Query 2 : **WHERE clause**: Number of Bookings in each Space Type between 1st February 2022 to 30th June 2022 */
SELECT s.SpaceType, COUNT(DISTINCT sb.Id) bookings
FROM spacebooking sb
INNER JOIN spaces s ON s.Id = sb.SpaceId
WHERE DATE(sb.bookingtime) >='2022-02-01'
AND DATE(sb.bookingtime)<'2022-07-01'
GROUP BY s.SpaceType;

/* Query 3 : **LEFT JOIN** : Neighbourhoods with MaxCapacity and Seats Booked */
SELECT b2.Neighbourhood, SUM(n.MaxCapacity) MaxCapacity, SUM(n.SeatsBooked) SeatsBooked
FROM
	(SELECT c.BuildingId, SUM(c.MaxCap) MaxCapacity, SUM(c.SeatBooked) SeatsBooked
	FROM
		(SELECT b.Id BuildingId , s.Id SpaceId, SUM(s.MaxCapacity) MaxCap, SUM(sb.NumSeatsBooked) SeatBooked
		FROM spaces s
		JOIN building b ON b.Id = s.BuildingId
		LEFT JOIN spacebooking sb ON sb.SpaceId = s.Id
		GROUP BY BuildingId, SpaceId) c
		GROUP BY BuildingId) n
JOIN building b2 ON b2.Id = n.BuildingId
GROUP BY Neighbourhood;

/*Query 4: **NESTED Query** : In what Neighbourhoods of Boston, does 'Photobug' use the SmartSpaces ? */
SELECT b.Neighbourhood
FROM building b
WHERE b.Id IN
	(SELECT s.BuildingId
	FROM spaces s
	WHERE s.Id IN
		(SELECT sb.SpaceId
		FROM spacebooking sb
		WHERE sb.UsersId IN (SELECT c.CorporatePocUsersId
		FROM corporate c
		WHERE c.CorporateName IN ('Photobug'))));


/* Query 5: **Correlated Query** Find top 5 corporates with maximum number of employees*/
SELECT c2.* FROM
(SELECT c.CorporateName, COUNT(e.Id) num_employees
FROM corporate c
JOIN employees e ON e.CorporateId = c.Id
GROUP BY c.CorporateName) c2
WHERE 5>
	(SELECT COUNT(*) FROM
		(SELECT c.CorporateName, COUNT(e.Id) num_employees
		FROM corporate c
		JOIN employees e ON e.CorporateId = c.Id
		GROUP BY c.CorporateName) c1
	WHERE c1.num_employees>c2.num_employees)
ORDER BY c2.num_employees DESC;


/*Query 6: **LEFT JOIN and Exists** - Distribution of Recurring users amongst Freelancers and Corporates */
SELECT COUNT(DISTINCT sb1.UsersId) total_reccurring_users,
COUNT(DISTINCT f.UsersId) freelancer_recurring,
COUNT(DISTINCT cp.UsersId) corporate_users
FROM spacebooking sb1
LEFT JOIN freelancer f ON f.UsersId = sb1.UsersId
LEFT JOIN corporatepoc cp ON cp.UsersId = sb1.UsersId
WHERE EXISTS (SELECT MIN(sb2.BookingTime) min_bookingtime
FROM spacebooking sb2
WHERE sb1.UsersId = sb2.UsersId
HAVING sb1.BookingTime> min_bookingtime);

/* Query 7: **NOT Exists** Find Users who have booked all 3 types of Spaces */
SELECT u2.*
FROM users u2
WHERE NOT EXISTS
	(SELECT *
	FROM spaces s2
	WHERE NOT EXISTS
		(SELECT u.Id UserId, s.SpaceType
		FROM spacebooking sb
		JOIN spaces s ON s.Id = sb.SpaceId
		JOIN users u ON u.Id = sb.UsersId
		WHERE s2.SpaceType = s.SpaceType
		AND u.Id = u2.Id));
        
/* Query 8: **ALL Clause**  What are the buildings in the neighborhoods with maximum revenue */
SELECT b.Neighbourhood, s.BuildingId, SUM(i.TotalBillingCost) revenue
FROM invoice i
JOIN spacebooking sb ON sb.Id = i.SpaceBookingId
JOIN spaces s ON s.Id = sb.SpaceId
JOIN building b On b.Id = s.BuildingId
GROUP BY b.Neighbourhood, s.BuildingId
HAVING revenue>= ALL ( SELECT t.building_rev FROM
(SELECT b.Neighbourhood, s.BuildingId,
SUM(i.TotalBillingCost) building_rev FROM invoice i
JOIN spacebooking sb ON sb.Id = i.SpaceBookingId
JOIN spaces s ON s.Id = sb.SpaceId
JOIN building b On b.Id = s.BuildingId
GROUP BY b.Neighbourhood, s.BuildingId) t
WHERE t.Neighbourhood = b.Neighbourhood );   

/*Query 9: **ANY** - Find all freelancers that have generated more revenue than any of the corporates */
SELECT f.UsersId, SUM(i.TotalBillingCost)
freelancer_revenue,
CONCAT(u.FirstName, " ",u.LastName) name,
CONCAT(f.HouseNumber, " ", f.Streetname, "
",
f.StreetSuffix, ", ", f.City, ", ", f.state)
address, f.Email, u.ContactNumber
FROM users u
JOIN freelancer f ON f.UsersId = u.Id
JOIN spacebooking sb ON sb.UsersId = u.Id
JOIN invoice i ON i.SpaceBookingId = sb.Id
GROUP BY 1
HAVING freelancer_revenue > ANY
(SELECT SUM(i.TotalBillingCost) rev
FROM users u
JOIN corporatepoc cp ON cp.UsersId = u.Id
JOIN spacebooking sb ON sb.UsersId = u.Id
JOIN invoice i ON i.SpaceBookingId = sb.Id
GROUP BY u.Id);


