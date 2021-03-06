macro_rules! decode_body_or_write_error {
    ($req:ident, $dt:ty, $resfn:expr) => {
        match $req.get::<::bodyparser::Struct<$dt>>() {
            Ok(Some(request_data)) => request_data,
            Err(err) => {
                let response = $resfn(Some(&err));
                let body = ::serde_json::to_string(&response).unwrap();
                return Ok(::iron::response::Response::with((
                    ::iron::headers::ContentType::json().0,
                    ::iron::status::BadRequest,
                    body,
                )));
            },
            _ => {
                let response = $resfn(None);
                let body = ::serde_json::to_string(&response).unwrap();
                return Ok(::iron::response::Response::with((
                    ::iron::headers::ContentType::json().0,
                    ::iron::status::BadRequest,
                    body,
                )));
            }
        }
    }
}

macro_rules! decode_query_or_write_error {
    ($req:ident, extract = $xfn:expr, missing = $err:expr) => {
        match $req.get_ref::<::urlencoded::UrlEncodedQuery>().ok().and_then($xfn) {
            Some(value) => value,
            None => {
                let body = ::serde_json::to_string(&$err).unwrap();
                return Ok(::iron::response::Response::with((
                    ::iron::headers::ContentType::json().0,
                    ::iron::status::BadRequest,
                    body,
                )));
            }
        }
    }
}

macro_rules! json_response {
    ($status:expr, $res:expr) => {{
        let body = ::serde_json::to_string(&$res).unwrap();
        Ok(::iron::response::Response::with((
            ::iron::headers::ContentType::json().0,
            $status,
            body,
        )))
    }}
}

macro_rules! try_do {
    ($b:block) => {
        (|| -> Result<_, _> { $b })()
    }
}

pub mod presenters;
pub mod presentations;
pub mod questions;
