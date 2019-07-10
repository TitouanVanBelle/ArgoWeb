import Vapor

final class NavItemTag: TagRenderer
{
    init() { }

    func render(tag: TagContext) throws -> Future<TemplateData>
    {
        let title = tag.parameters[0].string ?? ""
        let path = tag.parameters[1].string ?? "/"
        let url = URL(fileURLWithPath: path)

        var cssClass = ""
        if let currentPath = tag.parameters[2].string {
            let currentUrl = URL(fileURLWithPath: currentPath)
            if url.pathComponents.count == 1 || currentUrl.pathComponents.count == 1 {
                if url.pathComponents[0] == currentUrl.pathComponents[0], currentUrl.pathComponents.count == url.pathComponents.count  {
                    cssClass = "selected"
                }
            } else {
                if url.pathComponents[1] == currentUrl.pathComponents[1] {
                    cssClass = "selected"
                }
            }

        }

        let string = "<li class=\"\(cssClass)\"><a href=\"\(path)\">\(title)</a></li>"
        return tag.container.future(.string(string))
    }
}

