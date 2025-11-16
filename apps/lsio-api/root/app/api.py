from fastapi import FastAPI, HTTPException
from fastapi.openapi.docs import get_swagger_ui_html
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from keyvaluestore import KeyValueStore
from models import ImagesResponse
from pydantic import ValidationError
import json
import os
import traceback

URL = os.environ.get("URL", "http://localhost:8000")
api = FastAPI(docs_url=None, redoc_url=None, version="1.0", title="LinuxServer API", servers=[{"url": URL}])
api.mount("/static", StaticFiles(directory="static"), name="static")


@api.get("/", include_in_schema=False)
async def swagger_ui_html():
	return get_swagger_ui_html(openapi_url="/openapi.json", title="LinuxServer API", swagger_favicon_url="/static/logo.png")

async def get_status():
    with KeyValueStore() as kv:
        return kv["status"]

@api.get("/health", summary="Get the health status")
async def health():
    try:
        content = await get_status()
        status_code = 200 if content == "Success" else 500
        return JSONResponse(content=content, status_code=status_code)
    except Exception:
        print(traceback.format_exc())
        raise HTTPException(status_code=404, detail="Not found")

async def get_images():
    with KeyValueStore() as kv:
        return kv["images"]

@api.get("/api/v1/images", response_model=ImagesResponse, summary="Get a list of images", response_model_exclude_none=True)
async def images(include_config: bool = False, include_deprecated: bool = False):
    try:
        response = await get_images()
        image_response = ImagesResponse.model_validate_json(response)
        if not include_deprecated:
            image_response.exclude_deprecated()
        if not include_config:
            image_response.exclude_config()
        return image_response
    except ValidationError:
        print(traceback.format_exc())
        response = await get_images()
        content = json.loads(response)
        return JSONResponse(content=content)
    except Exception:
        print(traceback.format_exc())
        raise HTTPException(status_code=404, detail="Not found")

if __name__ == "__main__":
    api.run()
