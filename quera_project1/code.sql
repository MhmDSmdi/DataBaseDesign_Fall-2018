DELETE FROM Student
WHERE sID IN (
    SELECT ap1.sID
    FROM Apply AS ap1 CROSS JOIN Apply AS ap2 ON ap1.sID = ap2.sID
    WHERE ap1.major <> ap2.major
)