-- 姓名：xxx
-- 学号：xxx
-- 提交前请确保本次实验独立完成，若有参考请注明并致谢。

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q1
SELECT COUNT(*) speciesCount FROM species 
WHERE description like '%this%';
-- END Q1

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q2
SELECT a.username username,sum(b.power) totalPhonemonPower 
FROM player a,phonemon b 
WHERE a.id = b.player AND a.username IN ('Hughes','Cook') 
GROUP BY a.username;
-- END Q2

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q3
SELECT t.title,count(*) numberOfPlayers FROM team t,player p 
WHERE t.id = p.team GROUP BY t.title ORDER BY numberOfPlayers desc;
-- END Q3

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q4
SELECT s.id idSpecies,s.title FROM species s, type t 
WHERE t.title = 'grass' AND (t.id = s.type1 or t.id = s.type2);
-- END Q4

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q5
SELECT p.id idPlayer,username FROM player p 
WHERE p.id NOT IN (
    SELECT pu.player FROM purchase pu,food f WHERE f.id = pu.item);
-- END Q5

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q6
SELECT p.level,sum(it.price * pu.quantity) totalAmountSpentByAllPlayersAtLevel 
FROM player p,item it,purchase pu 
WHERE pu.item = it.id AND pu.player = p.id 
GROUP BY p.level 
ORDER BY totalAmountSpentByAllPlayersAtLevel desc;
-- END Q6

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q7
-- SELECT it.id item,it.title title,count(*) FROM item it,purchase p WHERE p.item = it.id GROUP BY item;
-- SELECT item,count(*) count FROM purchase GROUP BY item havINg count >= all(SELECT count(*) FROM purchase GROUP BY item);
SELECT it.id item,it.title title,count(*) numTimesPurchased 
FROM item it,purchase p WHERE p.item = it.id 
GROUP BY item 
havINg numTimesPurchased >=all(
    SELECT count(*) FROM purchase GROUP BY item);       
-- END Q7

-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q8
SELECT distinct p.id playerID,p.username username,count(distinct pu.item) numberDistinctFoodItemsPurchased
FROM player p,purchase pu,item it 
WHERE pu.player = p.id AND it.id = pu.item AND it.type = 'F'
    AND p.id IN
    (SELECT id FROM player WHERE 
    NOT exists(SELECT * FROM food f 
        WHERE NOT exists(SELECT * FROM purchase pur WHERE pur.item = f.id AND player.id = pur.player))
    )
    GROUP BY p.id;
-- END Q8
-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q9
SELECT count(*) numberOfPhonemonPairs,round(100 * mIN(sqrt((p1.latitude - p2.latitude)*(p1.latitude - p2.latitude) 
+ (p1.longitude - p2.longitude) * (p1.longitude - p2.longitude))),2) as distanceX 
FROM phonemon p1,phonemon p2 WHERE p1.id < p2.id AND
 (p1.latitude - p2.latitude)*(p1.latitude - p2.latitude) + 
 (p1.longitude - p2.longitude) * (p1.longitude - p2.longitude) <= all(
     SELECT (p3.latitude - p4.latitude)*(p3.latitude - p4.latitude) + 
     (p3.longitude - p4.longitude) * (p3.longitude - p4.longitude)  
     FROM phonemon p3,phonemon p4 WHERE p3.id < p4.id);
-- END Q9


-- ____________________________________________________________________________________________________________________________________________________________________________________________________________
-- BEGIN Q10
-- SELECT a.id,a.type,p.species,p.player FROM ( SELECT s1.id id ,s1.type1 type FROM species s1 union all  SELECT s2.id id,s2.type2 type FROM species s2 WHERE s2.type2 is NOT null)as a,phonemon p WHERE p.species = a.id;
-- SELECT a.type,p.species,p.player FROM ( SELECT s1.id id ,s1.type1 type FROM species s1 union all  SELECT s2.id id,s2.type2 type FROM species s2 WHERE s2.type2 is NOT null)as a,phonemon p WHERE p.species = a.id AND p.player is NOT null
SELECT p.username,t.title FROM player p,type t,
(
SELECT player pid,type tid FROM

    (
    SELECT count(distinct species) scount,player,type FROM (
    SELECT a.type,p.species,p.player FROM ( 
            SELECT s1.id id, s1.type1 type FROM species s1 
            union all  
            SELECT s2.id id, s2.type2 type FROM species s2 
            WHERE s2.type2 is NOT null)
            as a,
            phonemon p WHERE p.species = a.id AND p.player is NOT null
            ORDER BY a.type,p.species,p.player
        ) x
        GROUP BY player,type
    )y
WHERE (scount,type) IN 
(SELECT count(distinct sid) scount,type FROM(
 SELECT s1.id sid ,s1.type1 type FROM species s1 
 union all  
 SELECT s2.id sid,s2.type2 type FROM species s2 WHERE s2.type2 is NOT null
) x GROUP BY type)
)c
WHERE p.id = c.pid AND t.id = c.tid;
-- END Q10