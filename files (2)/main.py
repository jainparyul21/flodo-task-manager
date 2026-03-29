from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from typing import List, Optional
import asyncio

from database import SessionLocal, engine
import models, schemas

models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Flodo API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@app.get("/")
def root():
    return {"message": "Flodo API is running 🚀"}


@app.get("/tasks", response_model=List[schemas.TaskOut])
def get_tasks(
    search: Optional[str] = None,
    status: Optional[str] = None,
    db: Session = Depends(get_db)
):
    query = db.query(models.Task)
    if search:
        query = query.filter(models.Task.title.ilike(f"%{search}%"))
    if status and status != "All":
        query = query.filter(models.Task.status == status)
    tasks = query.order_by(models.Task.sort_order).all()
    return tasks


@app.get("/tasks/{task_id}", response_model=schemas.TaskOut)
def get_task(task_id: int, db: Session = Depends(get_db)):
    task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task


@app.post("/tasks", response_model=schemas.TaskOut)
async def create_task(task: schemas.TaskCreate, db: Session = Depends(get_db)):
    await asyncio.sleep(2)  # Simulated delay as per assignment
    
    # Assign sort_order as max + 1
    max_order = db.query(models.Task).count()
    
    db_task = models.Task(
        title=task.title,
        description=task.description,
        due_date=task.due_date,
        status=task.status,
        blocked_by_id=task.blocked_by_id,
        sort_order=max_order,
    )
    db.add(db_task)
    db.commit()
    db.refresh(db_task)
    return db_task


@app.put("/tasks/{task_id}", response_model=schemas.TaskOut)
async def update_task(task_id: int, task: schemas.TaskUpdate, db: Session = Depends(get_db)):
    await asyncio.sleep(2)  # Simulated delay as per assignment
    
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    update_data = task.dict(exclude_unset=True)
    for key, value in update_data.items():
        setattr(db_task, key, value)
    
    db.commit()
    db.refresh(db_task)
    return db_task


@app.delete("/tasks/{task_id}")
def delete_task(task_id: int, db: Session = Depends(get_db)):
    db_task = db.query(models.Task).filter(models.Task.id == task_id).first()
    if not db_task:
        raise HTTPException(status_code=404, detail="Task not found")
    
    # Unblock any tasks blocked by this one
    db.query(models.Task).filter(models.Task.blocked_by_id == task_id).update({"blocked_by_id": None})
    
    db.delete(db_task)
    db.commit()
    return {"message": "Task deleted"}


@app.patch("/tasks/reorder/bulk")
def reorder_tasks(order: schemas.ReorderRequest, db: Session = Depends(get_db)):
    for item in order.items:
        db.query(models.Task).filter(models.Task.id == item.id).update({"sort_order": item.sort_order})
    db.commit()
    return {"message": "Order updated"}
