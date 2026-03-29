from sqlalchemy import Column, Integer, String, Date, ForeignKey
from sqlalchemy.orm import relationship
from database import Base


class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    description = Column(String, default="")
    due_date = Column(String, nullable=False)  # stored as ISO string YYYY-MM-DD
    status = Column(String, default="To-Do")   # "To-Do" | "In Progress" | "Done"
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)
    sort_order = Column(Integer, default=0)

    blocked_by = relationship("Task", remote_side=[id], foreign_keys=[blocked_by_id])
