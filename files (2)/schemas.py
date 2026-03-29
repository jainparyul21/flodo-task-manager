from pydantic import BaseModel
from typing import Optional, List


class TaskBase(BaseModel):
    title: str
    description: Optional[str] = ""
    due_date: str
    status: Optional[str] = "To-Do"
    blocked_by_id: Optional[int] = None


class TaskCreate(TaskBase):
    pass


class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[str] = None
    status: Optional[str] = None
    blocked_by_id: Optional[int] = None
    sort_order: Optional[int] = None


class TaskOut(TaskBase):
    id: int
    sort_order: int

    class Config:
        from_attributes = True


class ReorderItem(BaseModel):
    id: int
    sort_order: int


class ReorderRequest(BaseModel):
    items: List[ReorderItem]
