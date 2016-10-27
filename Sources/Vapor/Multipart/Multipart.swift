/**
    Multipart data that can consist of a 
    single or multiple files or a single or
    multiple lines of String input.
*/
public enum Multipart {
    case files([File])
    case file(File)
    case input(String)
    case inputArray([String])
}

extension Multipart {
    /**
        A multipart File.
    */
    public struct File {
        public var name: String?
        public var type: String?
        public var data: Bytes
    }
}

/**
    Convenience accessors
*/
extension Multipart {
    public var file: File? {
        if case .file(let file) = self {
            return file
        }

        return nil
    }

    public var files: [File]? {
        switch self {
        case .files(let files):
            return files
        case .file(let file):
            return [file]
        default:
            return nil
        }
    }

    public var input: String? {
        if case .input(let string) = self {
            return string
        }

        return nil
    }

    @available(*, deprecated: 1.0, message: "Use `inputs` instead.")
    public var inputArray: [String]? {
        return inputs
    }

    public var inputs: [String]? {
        switch self {
        case .inputArray(let inputs):
            return inputs
        case .input(let input):
            return [input]
        default:
            return nil
        }
    }
}

extension Multipart {
    public func serialized(boundary: String, keyName: String) throws -> Bytes {
        var serialized = Bytes()

        inputs?.forEach { input in
            serialized += "--\(boundary)\r\n".bytes
            serialized += "Content-Disposition: form-data; name=\"\(keyName)\"\r\n\r\n".bytes
            serialized += input.bytes
            serialized += "\r\n".bytes
        }

        files?.forEach { file in
            let fileName = file.name ?? ""
            let type = file.type ?? ""

            serialized += "--\(boundary)\r\n".bytes
            serialized += "Content-Disposition: form-data; name=\"\(keyName)\"; filename=\"\(fileName)\"\r\n".bytes
            serialized += "Content-Type: \(type)\r\n\r\n".bytes
            serialized += file.data
            serialized += "\r\n".bytes
        }

        // close
        serialized += "--\(boundary)--\r\n".bytes
        return serialized
    }
}
