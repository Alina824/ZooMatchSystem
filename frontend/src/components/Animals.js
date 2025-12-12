import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Card, Row, Col, Button, Spinner } from 'react-bootstrap';
import api from '../services/api';

const Animals = () => {
  const [animals, setAnimals] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchAnimals();
  }, []);

  const fetchAnimals = async () => {
    try {
      const response = await api.get('/animals');
      setAnimals(response.data);
    } catch (error) {
      console.error('Ошибка загрузки животных:', error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <Spinner animation="border" />;
  }

  return (
    <div>
      <h2>Все животные</h2>
      <Row>
        {animals.map(animal => (
          <Col md={4} key={animal.id} className="mb-4">
            <Card>
              {animal.photoUrl && (
                <Card.Img variant="top" src={animal.photoUrl} />
              )}
              <Card.Body>
                <Card.Title>{animal.name}</Card.Title>
                <Card.Text>
                  <strong>Вид:</strong> {animal.speciesName}<br />
                  <strong>Зоопарк:</strong> {animal.zooName}<br />
                  <strong>Готов к составлению пары:</strong> {animal.readyForPairing ? 'Да' : 'Нет'}
                </Card.Text>
                <Link to={`/animals/${animal.id}`}>
                  <Button variant="primary">Подробнее</Button>
                </Link>
              </Card.Body>
            </Card>
          </Col>
        ))}
      </Row>
    </div>
  );
};

export default Animals;



